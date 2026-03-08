extends Node3D

# Impostazioni
@onready var ray: RayCast3D = $"../CameraPivot/Camera3D/InteractionRay"
@onready var inventory: Node = $"../PlayerInventory"

var current_target = null

func _process(_delta):
	if GameManager.is_game_over or GameManager.has_won:
		return
		
	if ray and ray.is_colliding():
		var collider = ray.get_collider()
		
		var interactable = null
		if collider and collider.has_method("interact"):
			interactable = collider
		elif collider and collider.get_parent().has_method("interact"):
			interactable = collider.get_parent()
			
		if interactable:
			current_target = interactable
			return
			
	current_target = null
		
func _unhandled_input(event):
	if GameManager.is_game_over or GameManager.has_won:
		return
		
	if not current_target:
		return
		
	# E | Sfama
	if event.is_action_pressed("interact"):
		current_target.interact(inventory)
		
	# F | Parla
	if event.is_action_pressed("talk") and current_target.has_method("talk"):
		current_target.talk()
