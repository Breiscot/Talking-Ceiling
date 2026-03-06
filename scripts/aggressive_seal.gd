extends CharacterBody3D

# Statistiche
@export var move_speed: float = 5.0
@export var attack_range: float = 2.0
@export var detection_range: float = 30.0
@export var attack_cooldown: float = 1.5

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer= $AnimationPlayer
@onready var attack_area: Area3D = $AttackArea
@onready var growl_audio: AudioStreamPlayer3D = $GrowlAudio

# Stato
enum State { SPAWNING, CHASING, ATTACKING, IDLE }
var current_state: State = State.SPAWNING
var target: Node3D = null
var last_attack_time: float = 0.0
var spawn_timer: float = 1.5

func _ready():
	target = get_tree().get_first_node_in_group("player")
	
	current_state = State.SPAWNING
	
func _physics_process(delta):
	if GameManager.is_game_over:
		velocity = Vector3.ZERO
		return
		
	# Gravità
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		
	match current_state:
		State.SPAWNING:
			_process_spawning(delta)
		State.CHASING:
			_process_chasing(delta)
		State.ATTACKING:
			_process_attacking(delta)
			
	move_and_slide()
	
func _process_spawning(delta):
	spawn_timer -= delta
	if spawn_timer <= 0:
		current_state = State.CHASING
		
func _process_chasing(_delta):
	if not target:
		target = get_tree().get_first_node_in_group("player")
		if not target:
			return
			
	var distance = global_position.distance_to(target.global_position)
	
	if distance <= attack_range:
		current_state = State.ATTACKING
		velocity.x = 0
		velocity.z = 0
		return
		
	nav_agent.target_position = target.global_position
	
	if not nav_agent.is_navigation_finished():
		var next_pos = nav_agent.get_next_path_position()
		var direction = (next_pos - global_position).normalized
		direction.y = 0
		
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		
		if direction.length() > 0.1:
			var target_rot = atan2(direction.x, direction.z)
			rotation.y = lerp_angle(rotation.y, target_rot, 0.15)
			
func _process_attacking(_delta):
	if not target:
		return
		
	var distance = global_position.distance_to(target.global_position)
	
	if distance > attack_range * 1.5:
		current_state = State.CHASING
		return
		
	# Guarda target
	var look_dir = (target.global_position - global_position).normalized
	look_dir.y = 0
	if look_dir.length() > 0.1:
		var target_rot = atan2(look_dir.x, look_dir.z)
		rotation.y = lerp_angle(rotation.y, target_rot, 0.2)
		
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_attack_time >= attack_cooldown:
		last_attack_time = current_time
		_attack()
		
func _attack():
	print("Foca aggressiva ti ha preso.")
	GameManager.trigger_game_over()
