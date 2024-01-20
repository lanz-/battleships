extends Node3D

@onready var shot_marker_scene: PackedScene = preload("res://scenes/shot_marker.tscn")
@onready var missile_scene: PackedScene = preload("res://scenes/missile.tscn")

var _current: Vector2i = Vector2i.ZERO
var _previous_shots: Dictionary = {}
var _disable_tap = false

const MISSILE_START_POS = Vector3(10, 6, 10)


func set_marker(marker: Node, pos: Vector2i):
	var new_trans = Transform3D(marker.transform.basis, Game.untranslate(pos))
	_current = pos

	Game.animate_move(marker, new_trans, 0.2)


func _fire_missile_at(pos: Vector2i):
	_disable_tap = true
	
	var pos3 = Game.untranslate(pos)
	var start_trans = Transform3D(Basis.IDENTITY, MISSILE_START_POS)
	start_trans = start_trans.looking_at(pos3)
	var target_trans = Transform3D(start_trans.basis, pos3)
	
	var missile = missile_scene.instantiate()
	missile.transform = start_trans
	add_child(missile)
	
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(missile, "transform", target_trans, 0.4)
	
	await tween.finished
	missile.destroy()
	_disable_tap = false


func _add_adjacent_miss_markers(ship):
	var tween = null 
	
	for point in ship.get_occupied_points().map(func (p): return Game.translate(p)):
		if not Game.is_in_field(point):
			continue
		
		if point in _previous_shots:
			continue
		
		_previous_shots[point] = true
		var shot_marker = shot_marker_scene.instantiate()
		shot_marker.position = Game.untranslate(point)
		shot_marker.scale = Vector3(0.01, 0.01, 0.01)
	
		add_child(shot_marker)
		if tween == null:
			tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_parallel()
		tween.tween_property(shot_marker, "scale", Vector3.ONE, 0.5)
	
	await tween.finished


func _is_hit(ships, shot_marker):
	for ship in ships.get_children():
		for point in ship.get_placed_points().map(func (p): return Game.translate(p)):
			if point == _current:
				shot_marker.set_hit()
				ship.damage(shot_marker)
				if ship.is_destroyed():
					ship.show()
					_add_adjacent_miss_markers(ship)
				return true
	
	return false


func resolve_shot(ships, marker):
	if _previous_shots.has(_current):
		return [false, false]

	marker.hide()
	await _fire_missile_at(_current)
	marker.show()

	var shot_marker = shot_marker_scene.instantiate()
	shot_marker.position = Game.untranslate(_current)
	shot_marker.scale = Vector3(0.01, 0.01, 0.01)
	
	add_child(shot_marker)
	_previous_shots[_current] = true
	
	var hit = _is_hit(ships, shot_marker)
	
	
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(shot_marker, "scale", Vector3.ONE, 0.5)
	await tween.finished
	

	return [true, hit]


func do_process(_delta, drag_plane, _ships, marker):
	if _disable_tap:
		return
	
	if Input.is_action_just_pressed("tap"):
		var new_pos: Vector2i = Game.translate(drag_plane.target_pos)
		if Game.is_in_field(new_pos):
			set_marker(marker, new_pos)
