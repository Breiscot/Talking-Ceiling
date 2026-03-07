extends Node3D

# Scene
@export var fish_scene: PackedScene
@export var water_scene: PackedScene
@export var fish_per_day: int = 5
@export var water_per_day: int = 4

var spawned: Array[Node] = []

func _ready():
	GameManager.day_started.connect(_on_new_day)
	
func _on_new_day(day: int):
	for item in spawned:
		if is_instance_valid(item):
			item.queue_free()
	spawned.clear()
	
	var points: Array[Marker3D] = []
	for child in get_children():
		if child is Marker3D:
			points.append(child)
			
	points.shuffle()
	
	var bonus = (day - 1)
	var idx = 0
	
	# Spawna FISH
	for i in range(fish_per_day + bonus):
		if idx >= points.size(): break
		_spawn(fish_scene, points[idx].global_position)
		idx += 1
		
	# Spawna WATER
	for i in range(water_per_day + bonus):
		if idx >= points.size(): break
		_spawn(water_scene, points[idx].global_position)
		idx += 1
		
func _spawn(scene: PackedScene, pos: Vector3):
	if not scene: return
	var obj = scene.instantiate()
	get_tree().current_scene.add_child(obj)
	obj.global_position = pos + Vector3(randf_range(-0.5, 0.5), 0.5, randf_range(-0.5, 0.5))
	spawned.append(obj)
