extends Area3D

@export var offset_from_camera: Vector3 = Vector3(0, -0.3, -0.2)

var xr_camera: XRCamera3D = null

func _ready():
	await get_tree().process_frame
	xr_camera = get_parent().get_node_or_null("XRCamera3D")
	
func _process(_delta):
	if not xr_camera:
		return
		
	var cam_pos = xr_camera.global_position
	var cam_forward = -Vector3(
		xr_camera.global_transform.basis.z.x,
		0,
		xr_camera.global_transform.basis.z.z
	).normalized()
	
	global_position = cam_pos + Vector3(0, offset_from_camera.y, 0) + cam_forward * abs(offset_from_camera.z)
