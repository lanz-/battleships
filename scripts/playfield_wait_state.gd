extends Node3D


var _previous_shots: Dictionary = {}

@onready var shot_marker_scene: PackedScene = preload("res://scenes/shot_marker.tscn")
@onready var missile_scene: PackedScene = preload("res://scenes/missile.tscn")

const MISSILE_START_POS = Vector3(10, 6, 10)


func _fire_missile_at(pos: Vector2i):
	var pos3 = Game.untranslate(pos)
	var start_trans = Transform3D(Basis.IDENTITY, MISSILE_START_POS)
	start_trans = start_trans.looking_at(pos3)
	var target_trans = Transform3D(start_trans.basis, pos3)
	
	var camera: Camera3D = get_viewport().get_camera_3d()
	
	var missile = missile_scene.instantiate()
	missile.transform = start_trans
	add_child(missile)
	
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(missile, "transform", target_trans, 0.4)
	
	await tween.finished
	missile.destroy()


func _add_adjacent_miss_markers(ship):
	for point in ship.get_occupied_points().map(func (p): return Game.translate(p)):
		if not Game.is_in_field(point):
			continue
		
		if point in _previous_shots:
			continue
		
		_previous_shots[point] = true


func _is_hit(pos, ships, shot_marker):
	for ship in ships.get_children():
		for point in ship.get_placed_points().map(func (p): return Game.translate(p)):
			if point == pos:
				shot_marker.set_hit()
				ship.damage(shot_marker)
				if ship.is_destroyed():
					_add_adjacent_miss_markers(ship)
				return true
	
	return false
	

func _try_shoot(pos: Vector2i, ships: Node3D):
	await _fire_missile_at(pos)
	
	var shot_marker = shot_marker_scene.instantiate()
	shot_marker.position = Game.untranslate(pos)
	shot_marker.scale = Vector3(0.01, 0.01, 0.01)
	
	add_child(shot_marker)
	_previous_shots[pos] = true
	
	var hit = _is_hit(pos, ships, shot_marker)
	
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(shot_marker, "scale", Vector3.ONE, 0.5)
	await tween.finished
	
	return hit


func resolve_enemy_shot(ships: Node3D):
	var is_hit = true
	
	while is_hit:
		var pos = Vector2i(randi_range(0, 9), randi_range(0, 9))
		while pos in _previous_shots:
			pos = Vector2i(randi_range(0, 9), randi_range(0, 9))
		
		await get_tree().create_timer(2.0).timeout
		is_hit = await _try_shoot(pos, ships)



func do_process(_delta, _drag_plane, _ships, _marker):
	pass
