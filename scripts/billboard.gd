extends Node3D

@export var use_x: bool = true
@export var use_y: bool = true
@export var use_z: bool = true

var camera: Camera3D = null

func _ready():
	await get_tree().process_frame
	_find_camera()
	
func _find_camera():
	var viewport = get_viewport()
	if viewport:
		camera = viewport.get_camera_3d()
		
	if not camera:
		var cameras = get_tree().get_nodes_in_group("player_camera")
		if cameras.size() > 0:
			camera = cameras[0]
			
	if not camera:
		print("Billboard: Camera not found.")
		
func _process(_delta):
	if not camera:
		return
		
	var target_pos = camera.global_position
	var current_pos = global_position
	var look_dir = (target_pos - current_pos).normalized()
	
	var target_rotation = Basis.looking_at(look_dir, Vector3.UP)
	
	var final_rotation = target_rotation.get_euler()
	
	if not use_x:
		final_rotation.x = 0
	if not use_y:
		final_rotation.y = 0
	if not use_z:
		final_rotation.z = 0
		
	rotation = final_rotation
