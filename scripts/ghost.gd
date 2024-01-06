extends Node3D

var ok_material = preload("res://resources/ghost_material.tres")
var wrong_material = preload("res://resources/ghost_wrong_material.tres")

func init(mesh_exemplars: Array[Node]):
	for exemplar in mesh_exemplars:
		var mesh: MeshInstance3D = exemplar.duplicate() as MeshInstance3D
		add_child(mesh)
		mesh.owner = self
		mesh.set_surface_override_material(0, ok_material)

func show_wrong():
	for mesh in get_children():
		mesh.set_surface_override_material(0, wrong_material)


func show_ok():
	for mesh in get_children():
		mesh.set_surface_override_material(0, ok_material)

func get_points():
	var points: Array[Vector3] = []
	for mesh in get_children():
		points.append(mesh.position)

	return points
