extends Node3D

@onready var drag_plane: Node = $grid_plane/drag_plane
@onready var ships: Node = $ships

const CELL_SIZE = 1
const ONE_ROT = deg_to_rad(90)
const OCCUPIED_POS = [
	Vector2i(-1,  1), Vector2i(0,  1), Vector2i(1,  1),
	Vector2i(-1,  0), Vector2i(0,  0), Vector2i(1,  0),
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
]
@onready var TRANSFORM1 = Transform3D.IDENTITY.rotated(Vector3.UP, -ONE_ROT)
@onready var TRANSFORM2 = Transform3D.IDENTITY.rotated(Vector3.UP, -(2 * ONE_ROT))

var drag_trans: Transform3D = Transform3D.IDENTITY 

var _drag: bool = false
var _draggable: Node = null
var _drag_offset: Vector3 = Vector3.ZERO
var _ghost: Node = null
var _tween: Tween = null


func _translate(pos: Vector3) -> Vector2i:
	return Vector2i(round(pos.x), round(pos.z))


func _untranslate(pos: Vector2i) -> Vector3:
	return Vector3(pos.x, 0, pos.y)


func is_ships_placed():
	for ship in ships.get_children():
		if not ship.placed:
			return false
	
	return true
	

func _try_place_ship(ship: Node3D, candidates: Dictionary):
	var points = ship.get_points().map(func (p): return _translate(ship.transform * p))
	for point in points:
		if point not in candidates:
			return false
	
	return true


func _remove_from_candidates(ship: Node3D, candidates: Dictionary):
	var points = ship.get_points().map(func (p): return _translate(ship.transform * p))
	for point in points:
		for occupied_off in OCCUPIED_POS:
			candidates.erase(point + occupied_off)


func _place_ship(ship: Node3D, candidates: Dictionary):
	var try_pos = Vector2i(randi_range(0, 9), randi_range(0, 9))
	ship.position = _untranslate(try_pos)
	for r in range(4):
		ship.rotate_y(ONE_ROT)
		if _try_place_ship(ship, candidates):
			_remove_from_candidates(ship, candidates)
			return true
	
	return false


func place_random():
	var candidates: Dictionary = {}
	for i in range(10):
		for j in range(10):
			candidates[Vector2i(i, j)] = true
			
	for ship in ships.get_children():
		while not _place_ship(ship, candidates):
			pass
	
	_validate_ships()


func rotate_ship(ship: Node):
	var ship_transform: Transform3D = ship.transform
	var next_transform = ship_transform.rotated_local(Vector3.UP, ONE_ROT)
	next_transform = next_transform.orthonormalized()

	_animate_move(ship, next_transform, 0.4)
	_tween.tween_callback(_validate_ships)


func hide_ships():
	for ship in ships.get_children():
		ship.hide()


func start_drag(draggable: Node):
	if _drag:
		return

	_draggable = draggable
	_ghost = draggable.ghost_scene.instantiate()
	add_child(_ghost)

	drag_trans = draggable.transform
	_ghost.transform = drag_trans
	_drag_offset = drag_trans.origin - drag_plane.target_pos
	
	_drag = true

func is_wrong_points(ship: Node, transform: Transform3D, points: Array[Vector3]) -> bool:
	for point in points:
		var point_rc: Vector2i = _translate(transform * point)
		if (point_rc.x > 9) or (point_rc.x < 0):
			return true
			
		if (point_rc.y > 9) or (point_rc.y < 0):
			return true
		
		for other_ship in ships.get_children():
			if other_ship == ship:
				continue
			
			for other_point in other_ship.get_points():
				var other_rc: Vector2i = _translate(other_ship.transform * other_point)
				for occupied_off in OCCUPIED_POS:
					if point_rc == (other_rc + occupied_off):
						return true
	
	return false

func _animate_move(obj, trans, time):
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(obj, "transform", trans, time)

func _validate_ghost(new_trans: Transform3D):
	if is_wrong_points(_draggable, new_trans, _ghost.get_points()):
		_ghost.show_wrong()
	else:
		_ghost.show_ok()


func _validate_ships():
	for ship in ships.get_children():
		var wrong_pos = is_wrong_points(ship, ship.transform, ship.get_points())
		if wrong_pos:
			ship.show_wrong()
			ship.placed = false
		else:
			ship.show_ok()
			ship.placed = true

	
func _do_drag(time):
	var new_pos = drag_plane.target_pos + _drag_offset
	var rc: Vector2i = _translate(new_pos)
	new_pos = Vector3(rc.x, 0.0, rc.y)
		
	if new_pos != drag_trans.origin:
		drag_trans.origin = new_pos
		_validate_ghost(drag_trans)

		_animate_move(_ghost, drag_trans, time)


func abort_drag():
	if not _drag:
		return
		
	_drag = false

	_ghost.queue_free()
	_ghost = null
	_draggable = null


func stop_drag():
	if not _drag:
		return
		
	_drag = false

	_animate_move(_draggable, drag_trans, 0.2)
	_tween.tween_callback(_validate_ships)
	_ghost.queue_free()
	_ghost = null
	_draggable = null


func _ready():
	for ship in ships.get_children():
		ship.start_drag.connect(start_drag)
		ship.abort_drag.connect(abort_drag)
		ship.rotate_ship.connect(rotate_ship)
	
	_validate_ships()


func _process(delta):
	if Input.is_action_just_released("tap"):
		stop_drag()
	
	if _drag:
		if Input.is_action_just_pressed("rotate"):
			_ghost.rotate_y(ONE_ROT)
			drag_trans = drag_trans.rotated(Vector3.UP, ONE_ROT)
			_validate_ghost(drag_trans)
			
		_do_drag(0.15)
