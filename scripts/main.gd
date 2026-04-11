extends Node3D

@onready var xr_origin = $XROrigin3D
@onready var desktop_player = $Player
@onready var vr_camera = $XROrigin3D/XRCamera3D
@onready var desktop_camera = $Player/CameraPivot/Camera3D


func _ready():
	await get_tree().process_frame
	
	if VRManager.is_vr_available:
		_setup_vr()
	else:
		_setup_desktop()
		
	GameManager.satisfaction = 0.0
	
func _setup_vr():
	if VRManager.enable_vr():
		# Attiva VR
		xr_origin.visible = true
		desktop_player.visible = false
		vr_camera.current = true
		
		# Disabilita controller desktop
		desktop_player.set_process(false)
		desktop_player.set_physics_process(false)
		
		print("VR mode is ON")
	else:
		_setup_desktop()
		
func _setup_desktop():
	# Modalità desktop
	xr_origin.visible = false
	desktop_player.visible = true
	desktop_camera.current = true
	
	# Disabilita VR
	VRManager.disable_vr()
	
	print("Desktop mode is ON")
	
# Switch con F11 VR/Desktop
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F11:
			if VRManager.is_vr_available:
				if VRManager.is_vr_mode:
					_setup_desktop()
				else:
					_setup_vr()
