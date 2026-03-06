extends Node3D

@export var aggressive_seal_scene: PackedScene
@export var spawn_points: Array[Marker3D] = []
@export var base_count: int = 1
@export var extra_per_day: int = 1

var spawned_seals: Array[Node3D] = []

func _ready():
	GameManager.aggressive_seals_triggered.connect(_on_spawn_aggressive)
	GameManager.day_started.connect(_on_new_day)
	
func _on_spawn_aggressive(count: int):
	if not aggressive_seal_scene:
		return
		
	var total = count
	
	for i in range(total):
		if spawn_points.size() == 0:
			return
			
		var point = spawn_points[randi() % spawn_points.size()]
		var seal = aggressive_seal_scene.instantiate()
		
		get_tree().current_scene.add_child(seal)
		seal.global_position = point.global_position
		
		spawned_seals.append(seal)
		
func _on_new_day(_day: int):
	for seal in spawned_seals:
		if is_instance_valid(seal):
			seal.queue_free()
	spawned_seals.clear()
