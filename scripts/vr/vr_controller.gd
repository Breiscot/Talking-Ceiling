extends XRController3D

@export var hand: String = "left" # "left" o "right"

# Grab
var is_grabbing: bool = false
var held_object = null

# Animation
var anim_player: AnimationPlayer = null
const HAND_ANIM = "No_RAction"

# Input valori
var trigger_value: float = 0.0
var grip_value: float = 0.0

# Laser (Only UI)
var laser: MeshInstance3D = null
var ray_length: float = 3.0
var laser_active: bool = false

var inventory = null
var chest_detector: Area3D = null
var hand_ui: Node3D = null

func _ready():
	button_pressed.connect(_on_button_pressed)
	button_released.connect(_on_button_released)
	input_float_changed.connect(_on_input_float_changed)
	
	if hand == "left":
		add_to_group("left_controller")
	else:
		add_to_group("right_controller")
	
	await get_tree().process_frame
	
	for child in get_children():
		if child is Node3D:
			var ap = child.get_node_or_null("AnimationPlayer")
			if ap:
				anim_player = ap
				break
			
	# Crea Laser
	_create_laser()
				
	await get_tree().create_timer(0.5).timeout
	
	_find_references()
	
func _find_references():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		inventory = player.get_node_or_null("PlayerInventory")
		
	# Find chest detector
	var origin = get_parent()
	if origin:
		chest_detector = origin.get_node_or_null("ChestDetector")
		
	print("Controller %s ready, " % hand)
	
func _process(_delta):
	if GameManager.is_game_over or GameManager.has_won:
		return
		
	_update_hand_animation()
	_update_held_object()
	_update_laser()
	
func _physics_process(_delta):
	pass
	
# INPUT
		
func _on_input_float_changed(name: String, value: float):
	match name:
		"trigger":
			trigger_value = value
		"grid":
			grip_value = value
			
			if value > 0.8 and not is_grabbing:
				_try_grab()
			elif value < 0.2 and is_grabbing:
				_try_deposit_or_release()
	
func _on_button_pressed(button_name: String):
	match button_name:
		"ax_button": # A o X Pulsante
			if held_object:
				_try_feed_seal()
			else:
				_interact()
		"by_button": # B o Y Pulsante
			_try_talk()
		"trigger_click":
			_interact_with_ui()
			
func _on_button_released(button_name: String):
	pass
	
# GRAB
			
func _try_grab():
	# Search near objects grabbable
	var space_state = get_world_3d().direct_space_state
	var shape_query = PhysicsShapeQueryParameters3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.3
	shape_query.shape = sphere
	shape_query.transform = global_transform
	
	var results = space_state.intersect_shape(shape_query)
	
	for result in results:
		var obj = result.collider
		if obj.is_in_group("grabbable") and obj.has_method("grab"):
			_grab_object(obj)
			return
			
	var ray_result = _do_raycast(0.5)
	if ray_result:
		var obj = ray_result.collider
		if obj.is_in_group("grabbable") and obj.has_method("grab"):
			_grab_object(obj)
			
func _grab_object(obj):
	held_object = obj
	is_grabbing = true
	obj.grab(self)
	print("Taken: %s" % obj.name)
	
func _try_deposit_or_release():
	if not held_object:
		return
		
# Check if the hand is near to chest
	if chest_detector and _is_near_chest():
		_deposit_to_inventory()
	else:
		_release_object()
		
func _is_near_chest() -> bool:
	if not chest_detector:
		return false
		
	var dist = global_position.distance_to(chest_detector.global_position)
	return dist < 0.3
	
func _deposit_to_inventory():
	if not held_object or not inventory:
		return
		
	var type = held_object.get_item_type() if held_object.has_method("get_item_type") else ""
	
	match type:
		"fish":
			if inventory.add_fish(1):
				print("Added fish to inventory.")
				held_object.queue_free()
				held_object = null
				is_grabbing = false
		"water":
			if inventory.add_water(1):
				print("Added water to inventory.")
				held_object.queue_free()
				held_object = null
				is_grabbing = false

func _release_object():
	if held_object and held_object.has_method("release"):
		held_object.release()
	held_object = null
	is_grabbing = false
	print("Object released.")
	
func force_grab(obj):
	_grab_object(obj)
	
# UPDATE HELD OBJECT

func _update_held_object():
	if not is_grabbing or not held_object:
		return
		
	if not is_instance_valid(held_object):
		held_object = null
		is_grabbing = false
		return
		
	held_object.global_position = global_position + (-global_transform.basis.z * 0.1)
	held_object.global_rotation = global_rotation
	
# INTERACTION
		
func _interact():
	var result = _do_raycast(3.0)
	if not result:
		return
		
	var target = _find_interactable(result.collider)
	if target and inventory:
		target.interact(inventory)
		
func _try_feed_seal():
	var result = _do_raycast(2.0)
	if not result:
		return
		
	var target = result.collider
	if target.has_method("feed") or target.get_parent().has_method("feed"):
		var seal = target if target.has_method("feed") else target.get_parent()
		
		if held_object:
			var type = held_object.get_item_type()
			if type == "fish":
				seal.seal_needs.feed(30.0)
			elif type == "water":
				seal.seal_needs.give_water(35.0)
				
			held_object.queue_free()
			held_object = null
			is_grabbing = false
			print("Gave food directly to Ceiling.")
	
func _try_talk():
	var result = _do_raycast(3.0)
	if not result:
		return
		
	var target = _find_interactable(result.collider)
	if target and target.has_method("talk"):
		target.talk()
		
func _interact_with_ui():
	laser_active = true
	await get_tree().create_timer(0.1).timeout
	laser_active = false
	
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
	laser.name = "Laser"
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
		
	var hand_ui_node = _find_hand_ui()
	var ui_visible = hand_ui_node and hand_ui_node.is_visible_ui if hand_ui_node else false
		
	laser.visible = ui_visible or laser_active
	
	if not laser.visible:
		return
		
	var result = _do_raycast(ray_length)
	var mat = laser.material_override as StandardMaterial3D
	
	if result and _find_interactable(result.collider):
		mat.albedo_color = Color(0.2, 1.0, 0.2, 0.7)
		mat.emission = Color(0.2, 1.0, 0.2)
	else:
		mat.albedo_color = Color(0.2, 0.6, 1.0, 0.7)
		mat.emission = Color(0.2, 0.6, 1.0)
		
func _find_hand_ui() -> Node:
	var origin = get_parent()
	if not origin:
		return null
		
	if hand == "left":
		return origin.get_node_or_null("LeftController/HandUILeft")
	else:
		return origin.get_node_or_null("RightController/HandUIRight")
		
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
