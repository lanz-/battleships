extends Area3D


var camera: Camera3D = null
var target_pos: Vector3 = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_viewport().get_camera_3d()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	var mouse_screen_pos: Vector2 = get_viewport().get_mouse_position()
	var to: Vector3 = camera.global_position + camera.project_ray_normal(mouse_screen_pos) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(camera.global_position, to, 0x2)
	
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	var result = space_state.intersect_ray(query)
	if result:
		target_pos = to_local(result.position)
