extends Node

var is_vr_available: bool = false
var is_vr_mode: bool = false
var xr_interface: XRInterface = null

func _ready():
	_check_vr()
	
func _check_vr():
	xr_interface = XRServer.find_interface("OpenXR")
	
	if xr_interface and xr_interface.is_initialized():
		is_vr_available = true
		print("VR finded")
	else:
		is_vr_available = false
		print("VR not finded, mode desktop")
		
func enable_vr() -> bool:
	if not xr_interface:
		xr_interface = XRServer.find_interface("OpenXR")
		
	if not xr_interface:
		print("Open XR not found.")
		return false
		
	if not xr_interface.is_initialized():
		if not xr_interface.initialize():
			print("Impossible initializing VR")
			return false
			
	is_vr_mode = true
	is_vr_available = true
	
	# Configura viewport VR
	var vp = get_viewport()
	vp.use_xr = true
	vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	vp.scaling_3d_scale = 1.0
	
	# Disabilita VSync
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	print("VR is ON")
	return true
		
func disable_vr():
	if xr_interface and is_vr_mode:
		get_viewport().use_xr = false
		xr_interface.uninitialize()
		is_vr_mode = false
		print("Mode desktop ON")
		
func toggle_vr():
	if is_vr_mode:
		disable_vr()
	else:
		enable_vr()
