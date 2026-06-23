extends RigidBody3D

# Tipo
enum CollectibleType { FISH, WATER }
@export var type: CollectibleType = CollectibleType.FISH
@export var amount: int = 1

var collected: bool = false
var spawn_protection: bool = true
var bob_start_y: float = 0.0
var initialized: bool = false

func _ready():
	add_to_group("grabbable")
	
	var area = Area3D.new()
	var shape = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.5
	shape.shape = sphere
	area.add_child(shape)
	add_child(area)
	area.body_entered.connect(_on_body_entered)
	
	spawn_protection = true
	await get_tree().create_timer(0.5).timeout
	bob_start_y = global_position.y
	initialized = true
	spawn_protection = false
	
	_setup_visual()
	
func _process(delta):
	if collected or not initialized:
		return
		
	if not is_instance_valid(get_parent()) or not (get_parent() is XRController3D):
		global_position.y = bob_start_y + sin(Time.get_ticks_msec() / 1000.0 * 2.0) * 0.3
		rotate_y(delta * 2.0)
		
func get_item_type() -> String:
	if type == CollectibleType.FISH:
		return "fish"
	return "water"
	
func grab(_controller):
	freeze = true
	gravity_scale = 0
	
func release():
	freeze = false
	gravity_scale = 1.0
	apply_central_impulse(Vector3(randf_range(-1,1), 0.5, randf_range(-1,1)))
	
func _on_body_entered(body):
	if collected or spawn_protection:
		return
		
	if body.is_in_group("player") and not body is XRController3D:
		var inv = body.get_node_or_null("PlayerInventory")
		if not inv:
			return
			
		var ok = false
		if type == CollectibleType.FISH:
			ok = inv.add_fish(amount)
		else:
			ok = inv.add_water(amount)
			
		if ok:
			collected = true
			queue_free()
			
func _setup_visual():
	var mesh = get_node_or_null("MeshInstance3D")
	if not mesh:
		return
		
	var mat = StandardMaterial3D.new()
	mat.emission_enabled = true
	
	if type == CollectibleType.FISH:
		mat.albedo_color = Color(0.3, 0.6, 0.9)
		mat.emission = Color(0.2, 0.4, 0.8)
	else:
		mat.albedo_color = Color(0.2, 0.8, 1.0)
		mat.emission = Color(0.1, 0.6, 1.0)
			
	mat.emission_energy_multiplier = 0.5
	mesh.material_override = mat

func get_interaction_text() -> String:
	if type == CollectibleType.FISH:
		return "[E] Collect fish"
	return "[E] Collect water"
	
func interact(inv):
	if collected:
		return
	var ok = false
	if type == CollectibleType.FISH:
		ok = inv.add_fish(amount)
	else:
		ok = inv.add_water(amount)
	if ok:
		collected = true
		queue_free()
