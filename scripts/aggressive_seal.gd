extends CharacterBody3D

# Statistiche
var move_speed: float = 6.0
var target: Node3D = null

func _ready():
	await get_tree().create_timer(0.5).timeout
	target = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta):
	if GameManager.is_game_over or not target:
		velocity = Vector3.ZERO
		return
		
	# Gravità
	if not is_on_floor():
		velocity.y -= 9.8 * delta
		
	var direction = (target.global_position - global_position).normalized()
	direction.y = 0
		
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
		
	if direction.length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), 0.15)
			
	move_and_slide()
