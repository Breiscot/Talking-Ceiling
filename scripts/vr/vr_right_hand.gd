extends XRController3D

var inventory = null

func _ready():
	button_pressed.connect(_on_button_pressed)
	
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		inventory = player.get_node_or_null("PlayerInventory")
		
func _on_button_pressed(button_name: String):
	match button_name:
		"trigger_click", "ax_button":
			_try_interact()
		"by_button":
			_try_talk()
			
func _try_interact():
	var result = _do_raycast(3.0)
	if not result:
		return
		
	var obj = result.collider
	var interactable = null
	
	if obj.has_method("interact"):
		interactable = obj
	elif obj.get_parent().has_method("interact"):
		interactable = obj.get_parent()
		
	if interactable and inventory:
		interactable.interact(inventory)
		
func _try_talk():
	var result = _do_raycast(3.0)
	if not result:
		return
		
	var obj = result.collider
	var target = null
	
	if obj.has_method("talk"):
		target = obj
	elif obj.get_parent().has_method("talk"):
		target = obj.get_parent()
		
	if target:
		target.talk()
		
func _do_raycast(distance: float) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var from = global_position
	var to = global_position + (-global_transform.basis.z * distance)
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	
	return space_state.intersect_ray(query)
