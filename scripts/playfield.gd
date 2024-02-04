extends Node3D

@onready var drag_plane: Node = $grid_plane/drag_plane
@onready var ships: Node = $ships
@onready var marker: Node = $Marker

@onready var state: Node = $PlaceShipState


func _ready():
	pass


func _process(delta):
	state.do_process(delta, drag_plane, ships, marker)


func enter_place_state():
	for ship in ships.get_children():
		ship.show()
		
		ship.start_drag.connect(start_drag)
		ship.abort_drag.connect(abort_drag)
		ship.rotate_ship.connect(rotate_ship)

	marker.hide()
	
	state = $PlaceShipState
	state.validate_ships(ships)


func enter_target_state():
	for ship in ships.get_children():
		ship.hide()
		
		ship.start_drag.disconnect(start_drag)
		ship.abort_drag.disconnect(abort_drag)
		ship.rotate_ship.disconnect(rotate_ship)

	marker.show()
	
	state = $TargetState
	state.set_marker(marker, Vector2i(5, 4))


func enter_wait_state():
	for ship in ships.get_children():	
		ship.start_drag.disconnect(start_drag)
		ship.abort_drag.disconnect(abort_drag)
		ship.rotate_ship.disconnect(rotate_ship)
	
	state = $WaitState


func enter_game_over_state():
	for ship in ships.get_children():
		ship.show()
	
	state = $WaitState


func no_alive_ships():
	for ship in ships.get_children():
		if not ship.is_destroyed():
			return false
	
	return true


func is_ships_placed():
	for ship in ships.get_children():
		if not ship.placed:
			return false
	
	return true

func place_random():
	state.place_random(ships)
	

func rotate_ship(ship: Node):
	state.rotate_ship(ship, ships)


func start_drag(draggable: Node):
	state.start_drag(draggable, drag_plane)


func abort_drag():
	state.abort_drag()


func stop_drag():
	state.stop_drag(ships)


func resolve_shot():
	return await state.resolve_shot(ships, marker)


func resolve_enemy_shot():
	await state.resolve_enemy_shot(ships, marker)


func serialize_ships():
	var result = []
	for ship in ships.get_children():
		result.append([ship.ship_segments, ship.transform])
	
	return result


func deserialize_ships(ship_list):
	for ship in ships.get_children():
		ship.placed = false
	
	for ship_data in ship_list:
		var segments = ship_data[0]
		var trans = ship_data[1]
		
		for ship in ships.get_children():
			if ship.placed:
				continue
			
			if ship.ship_segments != segments:
				continue
			
			ship.transform = trans
			ship.placed = true
			break
	
	state.validate_ships(ships)
