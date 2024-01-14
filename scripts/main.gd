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
	enemy_field.enter_place_state()
	enemy_field.place_random()
	enemy_field.enter_target_state()

	player_field.enter_place_state()

	fire_button.hide()


func _process(_delta):
	pass
	

func _look_at(transform):
	if _tween:
		_tween.kill()
		
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(main_camera, "transform", transform, 1.0)


func _on_start_button_pressed():
	if player_field.is_ships_placed():
		player_field.enter_wait_state()
		
		fire_button.show()
		start_button.hide()
		randomize_button.hide()
		
		_look_at(enemy_field_transform)


func _on_randomize_button_pressed():
	player_field.place_random()


func _on_fire_button_pressed():
	var resolution = await enemy_field.resolve_shot()
	var resolved = resolution[0]
	var extra_turn = resolution[1]
	
	if resolved and not extra_turn:
		fire_button.hide()
		await get_tree().create_timer(2.0).timeout
		_look_at(player_field_transform)
		await player_field.resolve_enemy_shot()
		await get_tree().create_timer(2.0).timeout
		_look_at(enemy_field_transform)
		fire_button.show()
