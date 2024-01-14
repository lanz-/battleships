extends Node3D

@onready var drag_plane: Node = $grid_plane/drag_plane
@onready var ships: Node = $ships
@onready var marker: Node = $Marker

@onready var state: Node = $PlaceShipState


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
	await state.resolve_enemy_shot(ships)


func _ready():
	pass


func _process(delta):
	state.do_process(delta, drag_plane, ships, marker)
