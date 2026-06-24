extends Camera3D

@export var bob_speed: float = 0.8
@export var bob_amount: float = 0.15
@export var transition_speed: float = 1.5

var start_position: Vector3
var target_camera: Camera3D = null
var is_transitioning: bool = false
var transition_progress: float = 0.0

var target_start_pos: Vector3
var target_start_rot: Vector3

func _ready():
	start_position = global_position
	current = true
	
func _process(delta):
	if is_transitioning:
		_do_transition(delta)
	else:
		_do_bob(delta)
		
func _do_bob(delta):
	var bob_y = sin(Time.get_ticks_msec() / 1000.0 * bob_speed) * bob_amount
	global_position.y = start_position.y + bob_y
	
func transition_to(cam: Camera3D):
	target_camera = cam
	target_start_pos = cam.global_position
	target_start_rot = cam.global_rotation
	is_transitioning = true
	transition_progress = 0.0
	
func _do_transition(delta):
	transition_progress += delta * transition_speed
	var t = clamp(transition_progress, 0.0, 1.0)
	
	# Smooth speed for fluid movement
	t = t * t * (3.0 - 2.0 * t)
	
	var bob_y = sin(Time.get_ticks_msec() / 1000.0 * bob_speed) * bob_amount
	var target_pos = target_start_pos + Vector3(0, bob_y, 0)
	
	global_position = start_position.lerp(target_pos, t)
	global_rotation = start_position.lerp(target_start_rot, t)
	
	if transition_progress >= 1.0:
		is_transitioning = false
		start_position = target_start_pos
		global_position = target_pos
		
func is_transition_done() -> bool:
	return not is_transitioning
