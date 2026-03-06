extends Area3D

# Tipo
enum CollectibleType { FISH, WATER }
@export var type: CollectibleType = CollectibleType.FISH
@export var amount: int = 1

# Animazione
@export var bob_speed: float = 2.0
@export var bob_height: float = 0.3
@export var rotate_speed: float = 60.0

# Effetti
@export var collect_sound: AudioStream
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer
@onready var particles: GPUParticles3D = $CollectParticles

var start_position: Vector3
var is_collected: bool = false

func _ready():
	start_position = global_position
	
	body_entered.connect(_on_body_entered)
	
	_setup_visual()
	
func _process(delta):
	if is_collected:
		return
		
	var new_y = start_position.y + sin(Time.get_ticks_msec() / 1000.0 * bob_speed) * bob_height
	global_position = Vector3(start_position.x, new_y, start_position.z)
	
	rotate_y(deg_to_rad(rotate_speed * delta))
	
func _setup_visual():
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
	if is_collected:
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
	
	if audio_player and collect_sound:
		audio_player.stream = collect_sound
		audio_player.play()
		
	if particles:
		particles.emitting = true
		
	if mesh:
		mesh.visible = false
		
	# Disabilità collisione
	set_deferred("monitoring", false)
	
	await get_tree().create_timer(1.0).timeout
	queue_free()
	
# Interazione
func get_interaction_text() -> String:
	match type:
		CollectibleType.FISH:
			return "Raccogli pesce"
		CollectibleType.WATER:
			return "Raccogli acqua"
	return "Raccogli"
	
func interact(player_interaction):
	var inventory = player_interaction.get_inventory()
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
