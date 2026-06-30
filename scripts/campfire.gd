extends Node3D

#Signals
signal fire_started
signal fire_dying
signal fire_died

# FireState
enum FireState { OFF, LIT, DYING }
var state: FireState = FireState.OFF
var fire_level: float = 0.0
var max_fire_level: float = 100.0

# Decay
@export var night_decay_rate: float = 2.0
@export var day_decay_rate: float = 0.0

# Alimentation
@export var wood_restore: float = 25.0
@export var night_only: bool = true

# Other
@onready var light: OmniLight3D = $CampfireLight
@onready var particles: GPUParticles3D = $FireParticles
@onready var fire_audio: AudioStreamPlayer3D = $FireAudio

# State
var is_night: bool = false
var is_lit: bool = false

func _ready():
	add_to_group("campfire")
	
	fire_level = max_fire_level
	state = FireState.LIT
	
	if fire_audio:
		fire_audio.stream = load("res://audio/sfx/campfire.ogg")
		fire_audio.autoplay = true
		fire_audio.finished.connect(_on_audio_finished)
		fire_audio.play()
	
	_update_visuals()
	
	await get_tree().process_frame
	_find_day_night_cycle()
		
func _process(delta):
	if GameManager.is_game_over or GameManager.is_paused:
		return
		
	is_night = GameManager.is_night
		
	_update_fire(delta)
	_update_visuals()
	
func _update_fire(delta):
	if state == FireState.OFF:
		return
		
	var decay = 0.0
	if is_night:
		decay = night_decay_rate * delta
	else:
		decay = day_decay_rate * delta
		
	fire_level -= decay
	fire_level = clamp(fire_level, 0.0, max_fire_level)
	
	if fire_level <= 0:
		_extinguish()
	elif fire_level < 20.0 and state != FireState.DYING:
		state = FireState.DYING
		fire_dying.emit()
		print("The fire is going out.")
	elif fire_level >= 20.0 and state == FireState.DYING:
		state = FireState.LIT
		
func _update_visuals():
	if not light:
		return
		
	var intensity = fire_level / max_fire_level
	light.light_energy = intensity * 3.0
	
	if particles:
		particles.emitting = state != FireState.OFF
		particles.amount = 50 + int(intensity * 150)
		
	if fire_audio:
		fire_audio.volume_db = -20 + intensity * 10
		
func add_wood(amount: float):
	if state == FireState.OFF:
		fire_level = amount
		state = FireState.LIT
		fire_started.emit()
		
		if fire_audio:
			fire_audio.play()
		
		print("Fire rekindled")
	else:
		fire_level = clamp(fire_level + amount, 0.0, max_fire_level)
		state = FireState.LIT
		print("Added wood. Fire: %.0f%%" % (fire_level / max_fire_level * 100))
		
	if GameManager.seal_needs:
		var warmth_increase = amount * 0.4
		GameManager.seal_needs.add_warmth(warmth_increase)
		print("Warmth of Ceiling increased.")
		
func _extinguish():
	state = FireState.OFF
	fire_level = 0.0
	fire_died.emit()
	
	if fire_audio:
		fire_audio.stop()
		
	print("The fire is out")
	
func _on_night_started():
	is_night = true
	print("Is night. Keep the fire lit for Ceiling.")
	
func _on_day_started():
	is_night = false
	print("Is day. Fire is no longer needed.")
	
func get_interaction_text() -> String:
	var inv = _find_inventory()
	if not inv:
		return "Campfire"
		
	if state == FireState.OFF:
		return "[E] Restart the fire (you need wood)"
	elif inv.wood > 0:
		return "[E] Add wood"
	else:
		return "You don't have any wood"
		
func interact(inventory):
	if not inventory:
		return
		
	if inventory.use_wood(1):
		add_wood(wood_restore)
		print("Added wood on fire")
	else:
		print("You don't have any wood")
		
func _find_inventory():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		return player.get_node_or_null("PlayerInventory")
	return null
	
func get_fire_level() -> float:
	return fire_level
	
func is_fire_lit() -> bool:
	return state != FireState.OFF

func _find_day_night_cycle():
	var day_night = get_tree().get_first_node_in_group("day_night")
	
	if day_night:
		if day_night.has_method("is_night_time"):
			is_night = day_night.is_night_time()
			
		if day_night.has_signal("night_started"):
			day_night.night_started.connect(_on_night_started)
			day_night.day_started.connect(_on_day_started)
		else:
			print("- Cycle day/night not found, the fire won't work well.")
			
func _on_audio_finished():
	if fire_audio and state != FireState.OFF:
		fire_audio.play()
