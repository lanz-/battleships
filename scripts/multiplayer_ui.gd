extends Control


signal return_from_menu
signal start_multiplayer

@onready var game_list_ui = $HBoxMain/ItemList
@onready var game_name_edit = $HBoxMain/VBoxButtons/GameName
@onready var create_button = $HBoxMain/VBoxButtons/CreateButton
@onready var join_button = $HBoxMain/VBoxButtons/JoinButton


# Called when the node enters the scene tree for the first time.
func _ready():
	Lobby.update_game_list.connect(_on_update_game_list)
	Lobby.connection_failed.connect(_on_connection_failed)
	Lobby.game_created.connect(_on_game_created)
	Lobby.game_joined.connect(_on_game_joined)


func _on_create_button_pressed():
	var game_name = game_name_edit.text
	if not game_name:
		return
	
	Game.host = true
	Lobby.create_game.rpc_id(1, game_name)


func _on_join_button_pressed():
	if not game_list_ui.is_anything_selected():
		return

	var selected_idx = game_list_ui.get_selected_items()[0]
	
	var game_name = game_list_ui.get_item_text(selected_idx)
	Game.host = false
	Lobby.join_game.rpc_id(1, game_name)


func _on_cancel_button_pressed():
	Lobby.disconnect_from_server()
	game_list_ui.clear()
	return_from_menu.emit()


func _on_update_game_list(game_list):
	game_list_ui.clear()
	for item in game_list:
		game_list_ui.add_item(item)
	
	game_list_ui.sort_items_by_text()


func _on_connection_failed():
	Lobby.disconnect_from_server()
	game_list_ui.clear()
	return_from_menu.emit()


func _on_game_created():
	game_name_edit.editable = false
	join_button.hide()
	create_button.hide()


func _on_game_joined():
	start_multiplayer.emit()


func enter_multiplayer():
	game_name_edit.editable = true
	join_button.show()
	create_button.show()
	Lobby.reconnect_to_server()

