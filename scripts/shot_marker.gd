extends Node3D


@onready var mesh: MeshInstance3D = $Mesh
@onready var smoke: CPUParticles3D = $Smoke
@onready var hit_material = preload("res://resources/ship_wrong_material.tres") 


func set_hit():
	mesh.set_surface_override_material(0, hit_material)
	smoke.emitting = true


func set_miss():
	mesh.set_surface_override_material(0, null)
	smoke.emitting = false


func stop_smoke():
	smoke.emitting = false


func _ready():
	pass # Replace with function body.


func _process(_delta):
	pass
