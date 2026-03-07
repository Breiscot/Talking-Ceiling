extends Node3D

# Scene
@export var fish_scene: PackedScene
@export var water_scene: PackedScene
@export var fish_per_day: int = 5
@export var water_per_day: int = 4
@export var spawn_radius: float = 30.0

var spawned: Array[Node] = []
var spawn_positions = []

func _ready():
	GameManager.day_started.connect(_on_new_day)
	
	_generate_spawn_positions()
	
func _generate_spawn_positions():
	spawn_positions.clear()
	
	var positions = [
		Vector3(8, 0.5, 10),
		Vector3(-10, 0.5, 8),
		Vector3(15, 0.5, -5),
		Vector3(-12, 0.5, 15),
		Vector3(5, 0.5, -12),
		Vector3(-8, 0.5, -10),
		Vector3(20, 0.5, 3),
		Vector3(-15, 0.5, -5),
		Vector3(3, 0.5, 18),
		Vector3(-5, 0.5, -18),
		Vector3(12, 0.5, 12),
		Vector3(-18, 0.5, 2),
		Vector3(7, 0.5, -8),
		Vector3(-3, 0.5, 12),
		Vector3(18, 0.5, -10),
		Vector3(-14, 0.5, -12),
		Vector3(10, 0.5, -15),
		Vector3(-7, 0.5, 20),
		Vector3(25, 0.5, 8),
		Vector3(-20, 0.5, -3),
	]
	
	spawn_positions = positions
	
func _on_new_day(day: int):
	print("Spawning resources per day %d..." % day)
	
	for item in spawned:
		if is_instance_valid(item):
			item.queue_free()
	spawned.clear()
	
	var available = spawn_positions.duplicate()
	available.shuffle()
	
	var bonus = (day - 1)
	var idx = 0
	
	# Spawna FISH
	for i in range(fish_per_day + bonus):
		if idx >= available.size():
			break
		_spawn(fish_scene, available[idx])
		idx += 1
		
	# Spawna WATER
	for i in range(water_per_day + bonus):
		if idx >= available.size():
			break
		_spawn(water_scene, available[idx])
		idx += 1
		
func _spawn(scene: PackedScene, pos: Vector3):
	if not scene:
		return
		
	var obj = scene.instantiate()
	get_tree().current_scene.add_child(obj)
	
	await get_tree().process_frame
	
	var final_pos = pos + Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0))
	obj.global_position = final_pos
	
	spawned.append(obj)
