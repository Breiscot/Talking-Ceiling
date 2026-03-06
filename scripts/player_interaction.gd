extends Node3D

# Impostazioni
@export var interaction_range: float = 3.0

@onready var ray_cast: RayCast3D = $CameraPivot/Camera3D/InteractionRay
@onready var inventory: Node = $""

# UI
@export var prompt_label: Label

# Stato
var current_interactable: Node = null

func _ready():
	if ray_cast:
		ray_cast.target_position = Vector3(0, 0, -interaction_range)
		ray_cast.enabled = true
		
func _process(_delta):
	if GameManager.is_game_over or GameManager.is_paused:
		return
		
	_check_interactables()
	
	if Input.is_action_just_pressed("interact") and current_interactable:
		_do_interact()
		
func _check_interactables():
	if not ray_cast or not ray_cast.is_colliding():
		_clear_prompt()
		return
		
	var collider = ray_cast.get_collider()
	
	if collider and collider.has_method("get_interaction_text"):
		current_interactable = collider
		_show_prompt(collider.get_interaction_text())
	else:
		# Controlla il parent (per Area3D)
		if collider and collider.get_parent().has_method("get_interaction_text"):
			current_interactable = collider.get_parent()
			_show_prompt(current_interactable.get_interaction_text())
		else:
			_clear_prompt()
			
func _do_interact():
	if current_interactable and current_interactable.has_method("interact"):
		current_interactable.interact(self)
		
func _show_prompt(text: String):
	if prompt_label:
		prompt_label.text = "[E] " + text
		prompt_label.visible = true
		
func _clear_prompt():
	current_interactable = null
	if prompt_label:
		prompt_label.visible = false
		
func get_inventory() -> Node:
	return inventory
	
func get_seal_needs() -> Node:
	return GameManager.seal_needs
