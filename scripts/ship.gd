extends Area3D

signal start_drag(ship)
signal abort_drag
signal rotate_ship(ship)

var ghost_scene: PackedScene = null
var ghost_prefab: PackedScene = preload("res://scenes/ghost.tscn")
var wrong_material = preload("res://resources/ship_wrong_material.tres")

@export var placed: bool = false
@export var drag_time: float = 0.2
@export var ship_segments: int = 1

@onready var shape_root = $ship_root
@onready var _drag_timer = $drag_timer


func _ready():
	var ghost = ghost_prefab.instantiate()

	ghost.init(shape_root.get_children())
	
	ghost_scene = PackedScene.new()
	ghost_scene.pack(ghost)
	
	_drag_timer.autostart = false
	_drag_timer.one_shot = true
	_drag_timer.wait_time = drag_time


func get_points():
	var points: Array[Vector3] = []
	for i in range(ship_segments):
		points.append(Vector3(-i, 0, 0))

	return points
	

func show_wrong():
	for mesh in shape_root.get_children():
		mesh.set_surface_override_material(0, wrong_material)


func show_ok():
	for mesh in shape_root.get_children():
		mesh.set_surface_override_material(0, null)
	

func _on_input_event(camera, event, position, normal, shape_idx):
	if Input.is_action_just_pressed("tap"):
		_drag_timer.start(drag_time)
		start_drag.emit(self)
	
	if Input.is_action_just_released("tap"):
		if _drag_timer.time_left:
			abort_drag.emit()
			rotate_ship.emit(self)
		_drag_timer.stop()
