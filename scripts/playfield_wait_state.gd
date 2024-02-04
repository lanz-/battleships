extends Node3D


var _previous_shots: Dictionary = {}
var _targeted_ships: Array[AITarget] = []

@onready var shot_marker_scene: PackedScene = preload("res://scenes/shot_marker.tscn")
@onready var missile_scene: PackedScene = preload("res://scenes/missile.tscn")

const MISSILE_START_POS = Vector3(10, 6, 10)


func _fire_missile_at(pos: Vector2i, marker: Node3D):
	var pos3 = Game.untranslate(pos)
	marker.position = pos3
	marker.show()
	
	var start_trans = Transform3D(Basis.IDENTITY, MISSILE_START_POS)
	start_trans = start_trans.looking_at(pos3)
	var target_trans = Transform3D(start_trans.basis, pos3)
	
	var missile = missile_scene.instantiate()
	missile.transform = start_trans
	add_child(missile)
	
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(missile, "transform", target_trans, 0.8)
	
	await tween.finished
	missile.destroy()
	marker.hide()


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
				var target_index = -1
				for i in _targeted_ships.size():
					var target = _targeted_ships[i]
					if target.at_pos(pos):
						target_index = i
						break
				
				if target_index == -1:
					_targeted_ships.append(AITarget.new(pos))
					target_index = _targeted_ships.size() - 1
				else:
					_targeted_ships[target_index].add_point(pos)
				
				shot_marker.set_hit()
				ship.damage(shot_marker)
				if ship.is_destroyed():
					if target_index != -1:
						_targeted_ships.remove_at(target_index)
					_add_adjacent_miss_markers(ship)

				return true

	return false
	

func _try_shoot(pos: Vector2i, ships: Node3D, marker: Node3D):
	var shot_marker = shot_marker_scene.instantiate()
	shot_marker.position = Game.untranslate(pos)
	shot_marker.scale = Vector3(0.01, 0.01, 0.01)
	add_child(shot_marker)
	_previous_shots[pos] = true
	
	await _fire_missile_at(pos, marker)
	
	var hit = _is_hit(pos, ships, shot_marker)
	
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(shot_marker, "scale", Vector3.ONE, 0.5)
	await tween.finished
	
	return hit


func _choose_shot_position():
	if Game.is_multiplayer:
		return await Lobby.fired_at
	
	await get_tree().create_timer(2.0).timeout
	if _targeted_ships:
		return _targeted_ships[0].next_position(_previous_shots)
	else:
		var pos = Vector2i(randi_range(0, 9), randi_range(0, 9))
		while pos in _previous_shots:
			pos = Vector2i(randi_range(0, 9), randi_range(0, 9))
		
		return pos
		

func _no_alive_ships(ships: Node3D):
	for ship in ships.get_children():
		if not ship.is_destroyed():
			return false
	
	return true


func resolve_enemy_shot(ships: Node3D, marker: Node3D):
	var is_hit = true
	
	while is_hit:
		if len(_previous_shots) >= 100:
			return
		
		if _no_alive_ships(ships):
			return
		
		var pos = await _choose_shot_position()

		is_hit = await _try_shoot(pos, ships, marker)
		if Game.is_multiplayer:
			Lobby.fence_fire()


func do_process(_delta, _drag_plane, _ships, _marker):
	pass
