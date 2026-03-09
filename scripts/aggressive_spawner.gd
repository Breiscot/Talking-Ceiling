extends Node3D

@export var seal_scene: PackedScene
@export var spawn_distance: float = 60.0
@export var seal_count: int = 12

var spawned = []

func _ready():
	GameManager.aggressive_seals_triggered.connect(_on_spawn)
	
func _on_spawn():
	if not seal_scene:
		return
		
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
		
	var center = player.global_position
	
	# Spawna foche in cerchio attorno al player
	for i in range(seal_count):
		var seal = seal_scene.instantiate()
		
		# Posizione in cerchio
		var angle = (float(i) / seal_count) * TAU
		var spawn_pos = center + Vector3(
			cos(angle) * spawn_distance,
			0.5,
			sin(angle) * spawn_distance
		)
		
		seal.position = spawn_pos
		get_tree().current_scene.call_deferred("add_child", seal)
		spawned.append(seal)
		
	await get_tree().create_timer(15.0).timeout
	if not GameManager.is_game_over:
		GameManager.trigger_game_over()
