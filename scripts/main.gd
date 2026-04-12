extends Node3D

@onready var desktop_player = $Player
@onready var xr_origin = $XROrigin3D

func _ready():
	await get_tree().process_frame
	
	GameManager.satisfaction = 0.0
	
	var xr = XRServer.find_interface("OpenXR")
	
	if xr and (xr.is_initialized() or xr.initialize()):
		_start_vr()
	else:
		_start_desktop()
	
func _start_vr():
	print("Start VR...")
	
	get_viewport().use_xr = true
	
	if desktop_player:
		var cam = desktop_player.get_node_or_null("CameraPivot/Camera3D")
		if cam:
			cam.current = false
			cam.set_process(false)
		
		desktop_player.set_process(false)
		desktop_player.set_physics_process(false)
		desktop_player.set_process_input(false)
		desktop_player.set_process_unhandled_input(false)
		desktop_player.visible = false
		
		for child in desktop_player.get_children():
			if child.has_method("set_process"):
				child.set_process(false)
			if child.has_method("set_physics_process"):
				child.set_physics_process(false)
				
	if xr_origin:
		xr_origin.visible = true
		var xr_cam = xr_origin.get_node_or_null("XRCamera3D")
		if xr_cam:
			xr_cam.current = true
			
	print("VR mode is ON")
		
func _start_desktop():
	get_viewport().use_xr = false
	
	if xr_origin:
		xr_origin.visible = false
		xr_origin.set_process(false)
		xr_origin.set_physics_process(false)
		
		var xr_cam = xr_origin.get_node_or_null("XRCamera3D")
		if xr_cam:
			xr_cam.current = false
			
	# Attiva desktop
	if desktop_player:
		desktop_player.visible = true
		desktop_player.set_process(true)
		desktop_player.set_physics_process(true)
		desktop_player.set_process_input(true)
		desktop_player.set_process_unhandled_input(true)
		
		var cam = desktop_player.get_node_or_null("CameraPivot/Camera3D")
		if cam:
			cam.current = true
			
		for child in desktop_player.get_children():
			if child.has_method("set_process"):
				child.set_process(true)
			if child.has_method("set_physics_process"):
				child.set_physics_process(true)
	
	print("Desktop mode is ON")
	
# Switch con F11 VR/Desktop
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F11:
			if get_viewport().use_xr:
				_start_desktop()
			else:
				var xr = XRServer.find_interface("OpenXR")
				if xr and (xr.is_initialized() or xr.initialize()):
					_start_vr()
