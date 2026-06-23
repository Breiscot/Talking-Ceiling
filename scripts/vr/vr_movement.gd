extends XROrigin3D

# Movimento
@export var move_speed: float = 4.0
@export var turn_speed: float = 60.0
@export var snap_turn_angle: float = 30.0
@export var use_snap_turn: bool = true

# Controller
@onready var left_controller: XRController3D = $LeftController
@onready var right_controller: XRController3D = $RightController
@onready var camera: XRCamera3D = $XRCamera3D

# Stato snap turn
var snap_cooldown: float = 0.0
var snap_cooldown_time: float = 0.3

# Gravità e suolo
var vertical_velocity: float = 0.0
var gravity: float = -9.8

var character_body: CharacterBody3D = null

func _ready():
	if get_parent() is CharacterBody3D:
		character_body = get_parent()
		
func _process(delta):
	if GameManager.is_game_over or GameManager.has_won or GameManager.is_paused:
		return
		
	_handle_movement(delta)
	_handle_turning(delta)
	
func _handle_movement(delta):
	if not left_controller:
		return
		
	# Levetta sinistra per il Movimento
	var input_vec = left_controller.get_vector2("primary")
	
	if input_vec.length() < 0.2:
		return
		
	var cam_basis = camera.global_transform.basis
	var forward = -Vector3(cam_basis.z.x, 0, cam_basis.z.z).normalized()
	var right = Vector3(cam_basis.x.x, 0, cam_basis.x.z).normalized()
	
	var direction = (forward * input_vec.y + right * input_vec.x).normalized()
	
	global_position += direction * move_speed * delta
	
func _handle_turning(delta):
	if not right_controller:
		return
		
	# Levetta destra per la Rotazione
	var input_vec = right_controller.get_vector2("primary")
	
	if use_snap_turn:
		# Rotazione a scatti
		snap_cooldown -= delta
		
		if abs(input_vec.x) > 0.7 and snap_cooldown <= 0:
			var snap_dir = sign(input_vec.x)
			rotate_y(deg_to_rad(-snap_turn_angle * snap_dir))
			snap_cooldown = snap_cooldown_time
	else:
		# Rotazione fluida
		if abs(input_vec.x) > 0.2:
			rotate_y(deg_to_rad(-turn_speed * input_vec.x * delta))
