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
	
func _process(delta):
	if is_collected or not is_ready:
		return
		
	var new_y = start_position.y + sin(Time.get_ticks_msec() / 1000.0 * bob_speed) * bob_height
	global_position = Vector3(start_position.x, new_y, start_position.z)
	
	rotate_y(deg_to_rad(rotate_speed * delta))
	
func _setup_visual():
	var mesh = get_node_or_null("MeshInstance3D")
	if not mesh:
		return
		
	var material = StandardMaterial3D.new()
	
	match type:
		CollectibleType.FISH:
			material.albedo_color = Color(0.3, 0.6, 0.9)
			material.emission_enabled = true
			material.emission = Color(0.2, 0.4, 0.8)
			material.emission_energy_multiplier = 0.5
		CollectibleType.WATER:
			material.albedo_color = Color(0.2, 0.8, 1.0)
			material.emission_enabled = true
			material.emission = Color(0.1, 0.6, 1.0)
			material.emission_energy_multiplier = 0.5
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			material.albedo_color.a = 0.8
			
	mesh.material_override = material
	
func _on_body_entered(body):
	if is_collected or spawn_protection:
		return
		
	if body.is_in_group("player") or body.name == "Player":
		var inventory = body.get_node_or_null("PlayerInventory")
		if not inventory:
			return
			
		var collected = false
		
		match type:
			CollectibleType.FISH:
				collected = inventory.add_fish(amount)
			CollectibleType.WATER:
				collected = inventory.add_water(amount)
				
		if collected:
			_collect()
			
func _collect():
	is_collected = true
	
	var mesh = get_node_or_null("MeshInstance3D")
	if mesh:
		mesh.visible = false
		
	# Disabilità collisione
	set_deferred("monitoring", false)
	
	queue_free()
	
# Interazione
func get_interaction_text() -> String:
	match type:
		CollectibleType.FISH:
			return "Collect fish"
		CollectibleType.WATER:
			return "Collect water"
	return "Collect"
	
func interact(inventory):
	if is_collected:
		return
		
	var collected = false
	match type:
		CollectibleType.FISH:
			collected = inventory.add_fish(amount)
		CollectibleType.WATER:
			collected = inventory.add_water(amount)
			
	if collected:
		_collect()
