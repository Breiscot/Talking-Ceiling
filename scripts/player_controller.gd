extends CharacterBody3D

# Movimento
@export var walk_speed: float = 5.0
@export var run_speed: float = 8.0
@export var jump_force: float = 4.5
@export var gravity: float = 15.0
@export var snow_slowdown: float = 0.85 # La neve rallenta

# Camera
@export var mouse_sensitivity: float = 0.002
@export var max_look_up: float = 89.0
@export var max_look_down: float = -89.0

# Altro
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var footstep_particles: GPUParticles3D = $FootstepParticles
@onready var footstep_audio: AudioStreamPlayer3D = $FootstepAudio
@onready var ray_cast: RayCast3D = $CameraPivot/Camera3D/InteractionRay

# Stato
var is_running: bool = false
var camera_rotation_x: float = 0.0

# Suoni dei passi
@export var footstep_sounds: Array[AudioStream] = []
var footstep_timer: float = 0.0
var footstep_interval: float = 0.5

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event):
	if GameManager.is_game_over or GameManager.is_paused:
		return
		
	if event is InputEventMouseMotion:
		# Rotazione orizzontale (player)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Rotazione verticale (camera)
		camera_rotation_x += -event.relative.y * mouse_sensitivity
		camera_rotation_x = clamp(
			camera_rotation_x,
			deg_to_rad(max_look_down),
			deg_to_rad(max_look_up)
		)
		camera_pivot.rotation.x = camera_rotation_x
		
	# Toggle mouse
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
func _physics_process(delta):
	if GameManager.is_game_over or GameManager.is_paused:
		return
		
	# Gravità
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		
	# Direzione movimento
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Velocità
	is_running = Input.is_action_pressed("run")
	var current_speed = run_speed if is_running else walk_speed
	current_speed *= snow_slowdown
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed * delta * 10)
		velocity.z = move_toward(velocity.z, 0, current_speed * delta * 10)

	move_and_slide()
	
	# Effetti passi
	_handle_footsteps(delta, direction)
	
func _handle_footsteps(delta: float, direction: Vector3):
	if is_on_floor() and direction.length() > 0.1:
		if footstep_particles and not footstep_particles.emitting:
			footstep_particles.emitting = true
			
		# Suoni passi
		footstep_timer -= delta
		if footstep_timer <= 0:
			footstep_timer = footstep_interval / (1.5 if is_running else 1.0)
			_play_footstep()
	else:
		if footstep_particles:
			footstep_particles.emitting = false
		footstep_timer = 0
		
func _play_footstep():
	if footstep_audio and footstep_sounds.size() > 0:
		footstep_audio.stream = footstep_sounds[randi() % footstep_sounds.size()]
		footstep_audio.pitch_scale = randf_range(0.8, 1.2)
		footstep_audio.play()
