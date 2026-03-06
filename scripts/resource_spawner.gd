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
