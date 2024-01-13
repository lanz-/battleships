extends Node3D


const player_field_transform: Transform3D = Transform3D(
	Vector3(-0.707107, 0, 0.707107),
	Vector3(0.5, 0.707107, 0.5),
	Vector3(-0.5, 0.707107, -0.5),
	Vector3(-4, 10, -4),
)

const enemy_field_transform: Transform3D = Transform3D(
	Vector3(-0.707107, 0, -0.707107),
	Vector3(-0.5, 0.707107, 0.5),
	Vector3(0.5, 0.707107, -0.5),
	Vector3(-4, 10, -4),
)

@onready var main_camera = $main_camera
@onready var player_field = $player_playfield
@onready var enemy_field = $enemy_playfield

@onready var fire_button = $Ui/TopWindow/VBoxContainer/FireButton
@onready var start_button = $Ui/TopWindow/VBoxContainer/StartButton
@onready var randomize_button = $Ui/TopWindow/VBoxContainer/RandomizeButton

@onready var _tween: Tween = null

func _ready():
	main_camera.transform = player_field_transform
	enemy_field.hide_ships()
	fire_button.hide()


func _process(delta):
	pass


func _on_start_button_pressed():
	if player_field.is_ships_placed():
		fire_button.show()
		start_button.hide()
		randomize_button.hide()
		if _tween:
			_tween.kill()
		
		_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		_tween.tween_property(main_camera, "transform", enemy_field_transform, 1.0)
		_tween.tween_callback(enemy_field.place_random)


func _on_randomize_button_pressed():
	player_field.place_random()
