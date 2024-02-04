extends Node3D


@onready var main_menu_ui = $MainMenuWindow
@onready var multiplayer_ui = $MultiplayerUI


func _ready():
	multiplayer_ui.return_from_menu.connect(_return_to_main)
	multiplayer_ui.start_multiplayer.connect(_start_multiplayer)


func _on_start_button_pressed():
	Game.start(false)


func _on_multiplayer_button_pressed():
	main_menu_ui.hide()
	multiplayer_ui.enter_multiplayer()
	multiplayer_ui.show()


func _return_to_main():
	multiplayer_ui.hide()
	main_menu_ui.show()


func _start_multiplayer():
	Game.start(true)
