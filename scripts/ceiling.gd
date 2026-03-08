extends CharacterBody3D

@export var seal_needs: Node # SealNeeds
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var seal_audio: AudioStreamPlayer3D = $AudioPlayer

# Suoni
@export var bark_sound: AudioStream

# Wandering
@export var move_speed: float = 2.0
@export var wait_time_min: float = 2.0
@export var wait_time_max: float = 5.0

@export var home_position: Vector3 = Vector3(3, 0, 3)
@export var wander_radius: float = 6.0

# Stato
enum SealState { IDLE, WANDERING, HAPPY, SAD, TALKING }
var current_state: SealState = SealState.IDLE
var wait_timer: float = 0.0

# Nutrizione
var fish_restore: float = 30.0
var water_restore: float = 35.0

func _ready():
	GameManager.seal = self
	GameManager.seal_needs = seal_needs
	
	home_position = global_position
	
	# Connette segnali della foca
	if seal_needs:
		seal_needs.status_danger.connect(_on_danger)
		seal_needs.status_critical.connect(_on_critical)
		seal_needs.status_safe.connect(_on_safe)
		seal_needs.seal_fed.connect(_on_fed)
		
	wait_timer = randf_range(wait_time_min, wait_time_max)
	
func _physics_process(delta):
	if GameManager.is_game_over:
		return
		
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		
	match current_state:
		SealState.IDLE:
			_process_idle(delta)
		SealState.WANDERING:
			_process_wandering(delta)
		SealState.HAPPY, SealState.TALKING, SealState.SAD:
			velocity.x = 0
			velocity.z = 0
			
	_enforce_boundary()
	move_and_slide()
	
func _process_idle(delta):
	velocity.x = 0
	velocity.z = 0
	wait_timer -= delta
	if wait_timer <= 0:
		_pick_random_point_in_zone()
		current_state = SealState.WANDERING
		
func _process_wandering(_delta):
	if nav_agent.is_navigation_finished():
		current_state = SealState.IDLE
		wait_timer = randf_range(wait_time_min, wait_time_max)
		velocity = Vector3.ZERO
		return
		
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	direction.y = 0
	
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	
	# Ruota verso la direzione
	if direction.length() > 0.1:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 0.1)
	
func _pick_random_point_in_zone():
	var angle = randf() * TAU
	var distance = randf() * wander_radius
	var target_pos = home_position + Vector3(
		cos(angle) * distance,
		0,
		sin(angle) * distance
	)
	nav_agent.target_position = target_pos
	
func _enforce_boundary():
	var dist_from_home = Vector3(global_position.x, 0, global_position.z).distance_to(
		Vector3(home_position.x, 0, home_position.z)
	)
	
	if dist_from_home > wander_radius:
		var dir_to_home = (home_position - global_position).normalized()
		dir_to_home.y = 0
		velocity.x = dir_to_home.x * move_speed * 2
		velocity.z = dir_to_home.z * move_speed * 2
		
func get_interaction_text() -> String:
	return "[E] Feed | [F] Talk"
	
func interact(inventory):
	if not seal_needs:
		return
		
	if seal_needs.hunger <= seal_needs.thirst:
		if inventory.use_fish():
			seal_needs.feed(fish_restore)
			_on_fed("food")
			return
		elif inventory.use_water():
			seal_needs.give_water(water_restore)
			_on_fed("water")
			return
	else:
		if inventory.use_water():
			seal_needs.give_water(water_restore)
			_on_fed("water")
			return
		elif inventory.use_fish():
			seal_needs.feed(fish_restore)
			_on_fed("food")
			return
			
func talk():
	current_state = SealState.TALKING
	
	if seal_audio and bark_sound:
		seal_audio.stream = bark_sound
		seal_audio.play()
		
	await get_tree().create_timer(2.0).timeout
	if current_state == SealState.TALKING:
		current_state = SealState.IDLE
		
func _on_fed(_type: String):
	current_state = SealState.HAPPY

	await get_tree().create_timer(2.0).timeout
	if not seal_needs.is_in_danger:
		current_state = SealState.IDLE
		
func _on_danger():
	current_state = SealState.SAD
		
func _on_critical():
	current_state = SealState.SAD
	
func _on_safe():
	current_state = SealState.IDLE
