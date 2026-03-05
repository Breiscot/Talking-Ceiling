extends CharacterBody3D

@export var seal_needs: Node # SealNeeds
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var happy_particles: GPUParticles3D = $HappyParticles
@onready var sad_particles: GPUParticles3D = $SadParticles
@onready var seal_audio: AudioStreamPlayer3D = $AudioPlayer

# Suoni
@export var happy_sound: AudioStream
@export var sad_sound: AudioStream
@export var idle_sound: AudioStream

# Wandering
@export var wander_points: Array[Marker3D] = []
@export var move_speed: float = 2.0
@export var wait_time_min: float = 2.0
@export var wait_time_max: float = 5.0
@export var wander_radius: float = 8.0

# Stato
enum SealState { IDLE, WANDERING, HAPPY, SAD }
var current_state: SealState = SealState.IDLE
var current_wander_index: int = 0
var wait_timer: float = 0.0
var is_waiting: bool = true

# Interazione
var interaction_area: Area3D

func _ready():
	GameManager.ceiling = self
	GameManager.seal_needs = seal_needs
	
	# Connette segnali della foca
	if seal_needs:
		seal_needs.status_danger.connect(_on_danger)
		seal_needs.status_critical.connect(_on_critical)
		seal_needs.status_safe.connect(_on_safe)
		seal_needs.seal_fed.connect(_on_fed)
		
	wait_timer = randf_range(wait_time_min, wait_time_max)
	current_state = SealState.IDLE
	
func _physics_process(delta):
	if GameManager.is_game_over:
		return
		
	match current_state:
		SealState.IDLE:
			_process_idle(delta)
		SealState.WANDERING:
			_process_wandering(delta)
		SealState.HAPPY:
			_process_happy(delta)
		SealState.SAD:
			_process_sad(delta)
			
	# Gravità
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		
	move_and_slide()
	
func _process_idle(delta):
	wait_timer -= delta
	if wait_timer <= 0:
		_pick_next_wander_point()
		current_state = SealState.WANDERING
		
func _process_wandering(_delta):
	if nav_agent.is_navigation_finished():
		current_state = SealState.IDLE
		wait_timer = randf_range(wait_time_min, wait_time_max)
		velocity = Vector3.ZERO
		return
		
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized
	direction.y = 0
	
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	# Ruota verso la direzione
	if direction.length() > 0.1:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 0.1)
		
func _process_happy(_delta):
	print("happy")
	
func _process_sad(_delta):
	print("sad")
	
func _pick_next_wander_point():
	if wander_points.size() > 0:
		current_wander_index = (current_wander_index + 1) % wander_points.size()
		nav_agent.target_position = wander_points[current_wander_index].global_position
	else:
		var random_offset = Vector3(
			randf_range(-wander_radius, wander_radius),
			0,
			randf_range(-wander_radius, wander_radius)
		)
		nav_agent.target_position = global_position + random_offset
		
func _on_fed(type: String):
	current_state = SealState.HAPPY
	
	if happy_particles:
		happy_particles.emitting = true
		
	if seal_audio and happy_sound:
		seal_audio.stream = happy_sound
		seal_audio.play()
		
	# Torna a idle dopo un pò
	await get_tree().create_timer(2.0).timeout
	if not seal_needs.is_in_danger:
		current_state = SealState.IDLE
		
func _on_danger():
	current_state = SealState.SAD
	
	if sad_particles:
		sad_particles.emitting = true
		
	if seal_audio and sad_sound:
		seal_audio.stream = sad_sound
		seal_audio.play()
		
func _on_critical():
	current_state = SealState.SAD
	
func _on_safe():
	if sad_particles:
		sad_particles.emitting = false
	current_state = SealState.IDLE
