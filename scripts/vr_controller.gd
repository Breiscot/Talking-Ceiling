extends XRController3D

@export var hand: String = "left" # "left" o "right"

# Grab
var is_grabbing: bool = false
var grabbed_object: Node3D = null

# Mano animata
var anim_player: AnimationPlayer = null
var inventory = null

# Input valori
var trigger_value: float = 0.0
var grip_value: float = 0.0

# Laser
var laser: MeshInstance3D = null
var ray_length: float = 3.0

const HAND_ANIM = "No_RAction"

func _ready():
	button_pressed.connect(_on_button_pressed)
	button_released.connect(_on_button_released)
	input_float_changed.connect(_on_input_float_changed)
	
	await get_tree().process_frame
	for child in get_children():
		var ap = child.get_node_or_null("AnimationPlayer")
		if ap:
			anim_player = ap
			print("AnimationPlayer founded on hand %s" % hand)
			break
			
	if not anim_player:
		push_warning("AnimationPlayer not founded on controller %s" % hand)
		
	# Specchia se é la mano sinistra
	for child in get_children():
		if child is Node3D and child.name != "laser":
			if hand == "left":
				child.scale.x = -1.0
				
	await get_tree().create_timer(0.5).timeout
	_find_inventory()
	
	# Crea Laser
	_create_laser()
	
func _process(_delta):
	if GameManager.is_game_over or GameManager.has_won:
		return
		
	_update_hand_animation()
	_update_laser()
	
func _physics_process(_delta):
	if is_grabbing and grabbed_object:
		grabbed_object.global_position = global_position + -global_transform.basis.z * 0.3
		
func _on_input_float_changed(name: String, value: float):
	match name:
		"trigger":
			trigger_value = value
		"grid":
			grip_value = value
	
func _on_button_pressed(button_name: String):
	match button_name:
		"trigger_click":
			_try_grab()
		"grip_click":
			_teleport()
		"ax_button": # A o X Pulsante
			_interact()
		"by_button": # B o Y Pulsante
			_try_talk()
			
func _on_button_released(button_name: String):
	match button_name:
		"trigger_click":
			_release_grab()
			
func _try_grab():
	var result = _do_raycast(2.0)
	if not result:
		return
		
	var obj = result.collider
	
	# Raccoglie collectible
	if obj.has_method("interact") and inventory:
		obj.interact(inventory)
		return
		
	if obj.is_in_group("grabbable"):
		grabbed_object = obj
		is_grabbing = true
		print("Grabbed: %s" % obj.name)
			
func _release_grab():
	if grabbed_object:
		print("Released: %s" % grabbed_object.name)
		grabbed_object = null
		is_grabbing = false
		
func _interact():
	var result = _do_raycast(3.0)
	if not result:
		return
		
	var target = _find_interactable(result.collider)
	if target and inventory:
		target.interact(inventory)
		print("Interacted with: %s" % target.name)
	
func _try_talk():
	var result = _do_raycast(3.0)
	if not result:
		return
		
	var target = _find_interactable(result.collider)
	if target and target.has_method("talk"):
		target.talk()
				
func _teleport():
	pass
	
func _update_hand_animation():
	if not anim_player:
		return
	if not anim_player.has_animation(HAND_ANIM):
		return
		
	var close_amount = max(trigger_value, grip_value)
	var anim_length = anim_player.get_animation(HAND_ANIM).length
	
	if not anim_player.is_playing():
		anim_player.play(HAND_ANIM)
		
	anim_player.seek(close_amount * anim_length, true)
	anim_player.pause()
	
func _create_laser():
	laser = MeshInstance3D.new()
	laser.name = "laser"
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = 0.002
	cylinder.bottom_radius = 0.002
	cylinder.height = ray_length
	laser.mesh = cylinder
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.6, 1.0, 0.5)
	mat.emission_enabled = true
	mat.emission = Color(0.2, 0.6, 1.0)
	mat.emission_energy_multiplier = 2.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	laser.material_override = mat
	laser.position = Vector3(0, 0, -ray_length / 2.0)
	laser.rotation_degrees.x = 90
	add_child(laser)
	laser.visible = false
	
func _update_laser():
	if not laser:
		return
		
	laser.visible = trigger_value > 0.1
	
	if not laser.visible:
		return
		
	var result = _do_raycast(ray_length)
	var mat = laser.material_override as StandardMaterial3D
	
	if result and _find_interactable(result.collider):
		mat.albedo_color = Color(0.2, 1.0, 0.2, 0.5)
		mat.emission = Color(0.2, 1.0, 0.2)
	else:
		mat.albedo_color = Color(0.2, 0.6, 1.0, 0.5)
		mat.emission = Color(0.2, 0.6, 1.0)
		
func _do_raycast(distance: float) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var from = global_position
	var to = from + (-global_transform.basis.z * distance)
	var query = PhysicsRayQueryParameters3D.create(from, to)
	return space_state.intersect_ray(query)
	
func _find_interactable(collider) -> Node:
	if collider.has_method("interact"):
		return collider
	if collider.get_parent().has_method("interact"):
		return collider.get_parent()
	return null

func _find_inventory():
	var vr_player = get_tree().get_first_node_in_group("player")
	if vr_player:
		inventory = vr_player.get_node_or_null("PlayerInventory")
		
	if not inventory:
		inventory = get_node_or_null("/root/Main/Player/PlayerInventory")
