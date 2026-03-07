extends Node3D

# Scene
@export var fish_scene: PackedScene
@export var water_scene: PackedScene

# Spawn points
@export var spawn_points: Array[Marker3D] = []

# Quantità
@export var fish_per_day: int = 5
@export var water_per_day: int = 4
@export var extra_per_day: int = 1

# Stato
var spawned_resources: Array[Node] = []

func _ready():
	GameManager.day_started.connect(_on_day_started)
	GameManager.resource_spawner = self
	
func _on_day_started(day: int):
	_clear_resources()
	_spawn_daily_resources(day)
	
func _spawn_daily_resources(day: int):
	var bonus = (day - 1) * extra_per_day
	
	var available_points = spawn_points.duplicate()
	available_points.shuffle()
	
	var point_index = 0
	
	# Spawna FISH
	var fish_count = fish_per_day + bonus
	for i in range(fish_count):
		if point_index >= available_points.size():
			break
		_spawn_resource(fish_scene, available_points[point_index])
		point_index += 1
		
	# Spawna WATER
	var water_count = water_per_day + bonus
	for i in range(water_count):
		if point_index >= available_points.size():
			break
		_spawn_resource(water_scene, available_points[point_index])
		point_index += 1
		
func _spawn_resource(scene: PackedScene, point: Marker3D):
	if not scene:
		return
		
	var resource = scene.instantiate()
	get_tree().current_scene.add_child(resource)
	resource.global_position = point.global_position
	
	# Offset casuale
	resource.global_position += Vector3(
		randf_range(-1.0, 1.0),
		0.5,	# Leggermente sopra il terreno
		randf_range(-1.0, 1.0)
	)
	
	spawned_resources.append(resource)
	
func _clear_resources():
	for res in spawned_resources:
		if is_instance_valid(res):
			res.queue_free()
	spawned_resources.clear()
