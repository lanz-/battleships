extends Control


signal return_from_menu
signal start_multiplayer

@onready var game_list_ui = $TopVBox/ItemHBox/ItemList
@onready var create_button = $TopVBox/ButtonHBox/CreateButton
@onready var join_button = $TopVBox/ButtonHBox/JoinButton
@onready var join_private_button = $TopVBox/ButtonHBox/JoinPrivateButton
@onready var modal_scene = preload("res://scenes/modal_window.tscn")


func _ready():
	Lobby.update_game_list.connect(_on_update_game_list)
	Lobby.connection_failed.connect(_on_connection_failed)
	Lobby.game_created.connect(_on_game_created)
	Lobby.game_joined.connect(_on_game_joined)


func _on_create_button_pressed():
	var modal = modal_scene.instantiate()
	add_child(modal)

	var result = await modal.show_modal(
		"Host a new game", true, "<game name>", true
	)
	var game_name = modal.edit.text
	var private = modal.private_check.button_pressed
	modal.queue_free()
	
	if (result != ModalWindow.OK) or (not game_name):
		return
	
	Game.host = true
	Lobby.create_game.rpc_id(1, game_name, private)


func _on_join_private_button_pressed():
	var modal = modal_scene.instantiate()
	add_child(modal)
	
	var result = await modal.show_modal(
		"Enter private game name", true, "<game name>", false
	)
	
	var game_name = modal.edit.text
	modal.queue_free()
	
	if (result != ModalWindow.OK) or (not game_name):
		return
	
	Game.host = false
	Lobby.join_game.rpc_id(1, game_name)


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
	join_button.hide()
	join_private_button.hide()
	create_button.hide()


func _on_game_joined():
	start_multiplayer.emit()


func enter_multiplayer():
	join_button.show()
	create_button.show()
	join_private_button.show()
	Lobby.reconnect_to_server()
