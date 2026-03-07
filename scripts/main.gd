extends Node3D

func _ready():
	await get_tree().process_frame
	GameManager.start_game()
