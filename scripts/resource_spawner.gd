extends Node3D

# Scene
@export var fish_scene: PackedScene
@export var water_scene: PackedScene
@export var fish_per_day: int = 8
@export var water_per_day: int = 6

var spawned = []
	
var spawn_positions = [
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
		_spawn_at(fish_scene, available[idx])
		idx += 1
		
	# Spawna WATER
	for i in range(water_per_day + bonus):
		if idx >= available.size():
			break
		_spawn_at(water_scene, available[idx])
		idx += 1
		
func _spawn_at(scene: PackedScene, pos: Vector3):
	if not scene:
		return
		
	var obj = scene.instantiate()
	
	var offset = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0))
	obj.position = pos + offset
	
	get_tree().current_scene.call_deferred("add_child", obj)
	
	spawned.append(obj)
