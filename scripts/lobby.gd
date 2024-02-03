extends Node

signal connection_failed
signal update_game_list(game_list)
signal game_joined
signal game_created

const SERVER_ADDRESS = "ws://127.0.0.1:5858"

var _game_list = []


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
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func reconnect_to_server():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null
	
	var peer = WebSocketMultiplayerPeer.new()
	peer.create_client(SERVER_ADDRESS)
	multiplayer.multiplayer_peer = peer


func disconnect_from_server():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer = null


@rpc("reliable")
func create_game(name: String):
	game_created.emit()


@rpc("reliable")
func join_game(name: String):
	game_joined.emit()


@rpc("reliable")
func set_game_list(game_list: Array):
	update_game_list.emit(game_list)
	set_game_list.rpc_id(1, game_list)


@rpc("reliable")
func placement_completed(goes_first: bool):
	print("Placement completed, goes first %s" % goes_first)
