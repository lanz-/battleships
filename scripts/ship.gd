extends Area3D

signal start_drag(ship)
signal abort_drag
signal rotate_ship(ship)

const SINK_ROT = deg_to_rad(180)
const OCCUPIED_POS = [
	Vector3(-1, 0, 0), Vector3(0, 0, 0), Vector3(1, 0, 0),
	Vector3(-1, 0, 1), Vector3(0, 0, 1), Vector3(1, 0, 1),
	Vector3(-1, 0,-1), Vector3(0, 0,-1), Vector3(1, 0,-1),
]

var ghost_scene: PackedScene = null
var ghost_prefab: PackedScene = preload("res://scenes/ghost.tscn")
var wrong_material = preload("res://resources/ship_wrong_material.tres")

var _damage: int = 0
var _markers: Array[Node3D] = []

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


func damage(marker):
	_markers.append(marker)
	_damage += 1
	if _damage >= ship_segments:
		var sink_trans = transform.rotated_local(Vector3.RIGHT, SINK_ROT).translated(Vector3.DOWN * 0.1)
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "transform", sink_trans, 3.0)
		for a_marker in _markers:
			a_marker.stop_smoke()


func is_destroyed() -> bool:
	return _damage >= ship_segments


func get_occupied_points() -> Array[Vector3]:
	var points: Array[Vector3] = []
	for point in get_placed_points():
		for offset in OCCUPIED_POS:
			points.append(point + offset)
	
	return points


func get_placed_points():
	return get_points().map(func (p): return transform * p)


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
	

func _on_input_event(_camera, _event, _position, _normal, _shape_idx):
	if Input.is_action_just_pressed("tap"):
		_drag_timer.start(drag_time)
		start_drag.emit(self)
	
	if Input.is_action_just_released("tap"):
		if _drag_timer.time_left:
			abort_drag.emit()
			rotate_ship.emit(self)
		_drag_timer.stop()
