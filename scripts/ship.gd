extends Area3D

var ghost_scene: PackedScene = null
var ghost_prefab: PackedScene = preload("res://scenes/ghost.tscn")
var wrong_material = preload("res://resources/ship_wrong_material.tres")

@export var playfield: Node = null
@export var placed: bool = false
@export var drag_time: float = 0.15

@onready var shape_root = $ship_root
@onready var _drag_timer = $drag_timer

const ONE_ROT = deg_to_rad(90)

@onready var TRANSFORM1 = Transform3D.IDENTITY.rotated(Vector3.UP, -ONE_ROT)
@onready var TRANSFORM2 = Transform3D.IDENTITY.rotated(Vector3.UP, -(2 * ONE_ROT))

var aligned = false


func _ready():
	var ghost = ghost_prefab.instantiate()

	ghost.init(shape_root.get_children())
	
	ghost_scene = PackedScene.new()
	ghost_scene.pack(ghost)
	
	_drag_timer.autostart = false
	_drag_timer.one_shot = true
	_drag_timer.wait_time = drag_time


func align():
	var trans: Transform3D = global_transform
	if aligned:
		return trans
	
	var init_rot_q = trans.basis.get_rotation_quaternion()
	var t1q = TRANSFORM1.basis.get_rotation_quaternion()
	var t2q = TRANSFORM2.basis.get_rotation_quaternion()
	var tbasis = TRANSFORM2.basis
	if t1q.angle_to(init_rot_q) < t2q.angle_to(init_rot_q):
		tbasis = TRANSFORM1.basis

	return Transform3D(tbasis, trans.origin)

func get_points():
	var points: Array[Vector3] = []
	for mesh in shape_root.get_children():
		points.append(mesh.position)

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
	
	if Input.is_action_just_released("tap"):
		if _drag_timer.time_left > 0:
			playfield.rotate_ship(self)
		_drag_timer.stop()


func _on_drag_timer_timeout():
	playfield.start_drag(self)
