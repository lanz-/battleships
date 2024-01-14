extends Node3D

const CELL_SIZE = 1
const ONE_ROT = deg_to_rad(90)
@onready var TRANSFORM1 = Transform3D.IDENTITY.rotated(Vector3.UP, -ONE_ROT)
@onready var TRANSFORM2 = Transform3D.IDENTITY.rotated(Vector3.UP, -(2 * ONE_ROT))

var drag_trans: Transform3D = Transform3D.IDENTITY 

var _drag: bool = false
var _draggable: Node = null
var _drag_offset: Vector3 = Vector3.ZERO
var _ghost: Node = null


func is_ships_placed(ships: Node3D) -> bool:
	for ship in ships.get_children():
		if not ship.placed:
			return false
	
	return true


func place_random(ships: Node3D):
	var candidates: Dictionary = {}
	for i in range(10):
		for j in range(10):
			candidates[Vector2i(i, j)] = true
			
	for ship in ships.get_children():
		while not _place_ship(ship, candidates):
			pass
	
	validate_ships(ships)


func rotate_ship(ship: Node, ships: Node3D):
	var ship_transform: Transform3D = ship.transform
	var next_transform = ship_transform.rotated_local(Vector3.UP, ONE_ROT)
	next_transform = next_transform.orthonormalized()

	Game.animate_move(ship, next_transform, 0.4).tween_callback(validate_ships.bind(ships))


func start_drag(draggable: Node, drag_plane: Node3D):
	if _drag:
		return

	_draggable = draggable
	_ghost = draggable.ghost_scene.instantiate()
	add_child(_ghost)

	drag_trans = draggable.transform
	_ghost.transform = drag_trans
	_drag_offset = drag_trans.origin - drag_plane.target_pos
	
	_drag = true


func validate_ships(ships: Node3D):
	for ship in ships.get_children():
		var wrong_pos = is_wrong_points(ship, ship.transform, ship.get_points(), ships)
		if wrong_pos:
			ship.show_wrong()
			ship.placed = false
		else:
			ship.show_ok()
			ship.placed = true


func is_wrong_points(ship: Node, test_transform: Transform3D, points: Array[Vector3], ships: Node3D) -> bool:
	for point in points:
		var point_rc: Vector2i = Game.translate(test_transform * point)
		if not Game.is_in_field(point_rc):
			return true
		
		for other_ship in ships.get_children():
			if other_ship == ship:
				continue
			
			for other_point in other_ship.get_occupied_points():
				var other_rc: Vector2i = Game.translate(other_point)
				if point_rc == other_rc:
					return true
	
	return false


func abort_drag():
	if not _drag:
		return
		
	_drag = false

	_ghost.queue_free()
	_ghost = null
	_draggable = null


func stop_drag(ships: Node3D):
	if not _drag:
		return
		
	_drag = false

	var tween = Game.animate_move(_draggable, drag_trans, 0.2)
	tween.tween_callback(validate_ships.bind(ships))

	_ghost.queue_free()
	_ghost = null
	_draggable = null


func do_process(_delta, drag_plane, ships, _marker):
	if Input.is_action_just_released("tap"):
		stop_drag(ships)
	
	if _drag:
		_do_drag(0.15, drag_plane, ships)
	

func _try_place_ship(ship: Node3D, candidates: Dictionary):
	var points = ship.get_placed_points().map(func (p): return Game.translate(p))
	for point in points:
		if point not in candidates:
			return false
	
	return true


func _remove_from_candidates(ship: Node3D, candidates: Dictionary):
	for point in ship.get_occupied_points().map(func (p): return Game.translate(p)):
		candidates.erase(point)


func _place_ship(ship: Node3D, candidates: Dictionary):
	var try_pos = Vector2i(randi_range(0, 9), randi_range(0, 9))
	ship.position = Game.untranslate(try_pos)
	for r in range(4):
		ship.rotate_y(ONE_ROT)
		if _try_place_ship(ship, candidates):
			_remove_from_candidates(ship, candidates)
			return true
	
	return false


func _validate_ghost(new_trans: Transform3D, ships: Node3D):
	if is_wrong_points(_draggable, new_trans, _ghost.get_points(), ships):
		_ghost.show_wrong()
	else:
		_ghost.show_ok()

	
func _do_drag(time, drag_plane, ships):
	var new_pos = drag_plane.target_pos + _drag_offset
	var rc: Vector2i = Game.translate(new_pos)
	new_pos = Vector3(rc.x, 0.0, rc.y)
		
	if new_pos != drag_trans.origin:
		drag_trans.origin = new_pos
		_validate_ghost(drag_trans, ships)

		Game.animate_move(_ghost, drag_trans, time)
