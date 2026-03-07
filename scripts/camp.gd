extends Node3D

@onready var interaction_area: Area3D = $InteractionArea
@onready var campfire_light: OmniLight3D = $CampfireModel/CampfireLight

# Impostazioni
@export var warmth_radius: float = 5.0
@export var fire_flicker_speed: float = 10.0
@export var fire_flicker_amount: float = 0.3

var day_night_cycle: Node = null
var base_light_energy: float = 2.0

func _ready():
	day_night_cycle = get_tree().get_first_node_in_group("day_night")
	
	if campfire_light:
		base_light_energy = campfire_light.light_energy
		
func _process(_delta):
	if campfire_light:
		var flicker = sin(Time.get_ticks_msec() / 1000.0 * fire_flicker_speed) * fire_flicker_amount
		campfire_light.light_energy = base_light_energy + flicker
		
# Interazione
func get_interaction_text() -> String:
	if day_night_cycle and day_night_cycle.can_sleep:
		var seal_needs = GameManager.seal_needs
		if seal_needs and seal_needs.is_critical:
			return "La foca é in pericolo, non puoi dormire."
		return "Dormi fino al giorno dopo"
	else:
		return "Puoi dormire solo di notte"
		
func interact(_player_interaction):
	if not day_night_cycle:
		day_night_cycle = get_tree().get_first_node_in_group("day_night")
		
	if not day_night_cycle:
		print("Err. DayNightCycle non trovato.")
		return
		
	# Controlla se é notte
	if not day_night_cycle.can_sleep:
		# Non é ancora notte
		return
		
	# Controlla stato foca
	var seal_needs = GameManager.seal_needs
	if seal_needs and seal_needs.is_critical:
		# Non può dormire, stato critico della foca
		return
		
	day_night_cycle.sleep()
