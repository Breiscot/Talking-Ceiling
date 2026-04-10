extends XRController3D

@export var hand: String = "left" # "left" o "right"

var is_grabbing: bool = false
var grabbed_object: Node3D = null

func _ready():
	button_pressed.connect(_on_button_pressed)
	button_released.connect(_on_button_released)
	
func _on_button_pressed(button_name: String):
	match button_name:
		"trigger_click":
			_try_grab()
		"grip_click":
			_teleport()
		"ax_button": # A o X Pulsante
			_interact()
			
func _on_button_released(button_name: String):
	match button_name:
		"trigger_click":
			_release_grab()
			
func _try_grab():
	# Raycast per afferrare oggetti
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + -global_transform.basis.z * 2.0
	)
	var result = space_state.intersect_ray(query)
	
	if result:
		var obj = result.collider
		if obj.is_in_group("grabbable"):
			grabbed_object = obj
			is_grabbing = true
			
func _release_grab():
	if grabbed_object:
		print("Released: %s" % grabbed_object.name)
		grabbed_object = null
		is_grabbing = false
		
func _interact():
	# Interagisci con Ceiling
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + -global_transform.basis.z * 3.0
	)
	var result = space_state.intersect_ray(query)
	
	if result:
		var obj = result.collider
		if obj.has_method("interact"):
			var inventory = get_node("/root/Main/Player/PlayerInventory")
			if inventory:
				obj.interact(inventory)
				
func _teleport():
	pass
	
func _physics_process(_delta):
	if is_grabbing and grabbed_object:
		grabbed_object.global_position = global_position + -global_transform.basis.z * 0.3
