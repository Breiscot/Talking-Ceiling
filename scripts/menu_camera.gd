extends Camera3D

@export var bob_speed: float = 0.8
@export var bob_amount: float = 0.15
@export var transition_speed: float = 2.0

var start_position: Vector3
var start_rotation: Quaternion

var target_position: Vector3
var target_rotation: Quaternion

var is_transitioning: bool = false
var transition_progress: float = 0.0

func _ready():
	start_position = global_position
	start_rotation = global_transform.basis.get_rotation_quaternion()
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
	start_position = global_position
	start_rotation = global_transform.basis.get_rotation_quaternion()
	target_position = cam.global_position
	target_rotation = cam.global_transform.basis.get_rotation_quaternion()
	
	is_transitioning = true
	transition_progress = 0.0
	
func _do_transition(delta):
	transition_progress += delta * transition_speed
	var t = clamp(transition_progress, 0.0, 1.0)
	
	# Smooth speed for fluid movement
	t = t * t * (3.0 - 2.0 * t)
	
	var bob_y = sin(Time.get_ticks_msec() / 1000.0 * bob_speed) * bob_amount
	var pos = start_position.lerp(target_position, t)
	pos.y += bob_y
	global_position = pos
	
	var rot = start_rotation.slerp(target_rotation, t)
	global_transform.basis = Basis(rot)
	
	if transition_progress >= 1.0:
		is_transitioning = false
		start_position = target_position
		
func is_transition_done() -> bool:
	return not is_transitioning
