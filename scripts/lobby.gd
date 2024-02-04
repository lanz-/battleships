extends Node

signal connection_failed
signal update_game_list(game_list)
signal game_joined
signal game_created
signal game_can_start
signal show_ships
signal fired_at(pos)

signal _fence

const SERVER_ADDRESS = "ws://127.0.0.1:5858"

var _fence_flag = false


# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_connected_to_server():
	print("Connected to ", multiplayer.multiplayer_peer)


func _on_connection_failed():
	connection_failed.emit()


func _on_server_disconnected():
	connection_failed.emit()
	

func reconnect_to_server():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null
	
	var peer = WebSocketMultiplayerPeer.new()
	peer.create_client(SERVER_ADDRESS)
	multiplayer.multiplayer_peer = peer


func disconnect_from_server():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null


func fence_start():
	_fence_flag = false


func fence_wait():
	if _fence_flag:
		return
	
	await _fence


func fence_fire():
	fence_fire_remote.rpc_id(1)


@rpc("reliable")
func create_game(_name: String):
	game_created.emit()


@rpc("reliable")
func join_game(_name: String):
	game_joined.emit()


@rpc("reliable")
func set_game_list(game_list: Array):
	update_game_list.emit(game_list)
	set_game_list.rpc_id(1, game_list)


@rpc("reliable")
func placement_completed(ship_list: Array):
	game_can_start.emit(ship_list)


@rpc("reliable")
func fire_at(pos: Vector2i):
	fired_at.emit(pos)


@rpc("reliable")
func fence_fire_remote():
	_fence_flag = true
	_fence.emit()


@rpc("reliable")
func peer_left_the_game():
	connection_failed.emit()
