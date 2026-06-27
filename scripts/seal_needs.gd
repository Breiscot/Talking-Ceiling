extends Node

# Segnali
signal hunger_changed(value: float)
signal thirst_changed(value: float)
signal warmth_changed(value: float)
signal status_danger
signal status_critical
signal status_safe
signal seal_fed(type: String)

# Bisogni
var hunger: float = 100.0
var thirst: float = 100.0
var warmth: float = 100.0
var max_value: float = 100.0
var max_warmth: float = 100.0

@export var hunger_decay: float = 2.0
@export var thirst_decay: float = 2.5

@export var danger_threshold: float = 20.0
@export var critical_threshold: float = 5.0

var is_in_danger: bool = false
var is_critical: bool = false

func _ready():
	GameManager.seal_needs = self
	GameManager.level_changed.connect(_on_level_changed)
	
func _on_level_changed(level: int):
	is_in_danger = false
	is_critical = false
	hunger = 80.0
	thirst = 80.0

func _process(delta):
	if GameManager.is_paused or GameManager.is_game_over:
		return
		
	# Diminuisci bisogni
	hunger -= hunger_decay * delta
	thirst -= thirst_decay * delta
	
	if GameManager.is_night:
		var campfire = GameManager.campfire
		var fire_lit = false
		
		if campfire and campfire.has_method("is_fire_lit"):
			fire_lit = campfire.is_fire_lit()
			
		if fire_lit:
			warmth += 0.1 * delta
		else:
			warmth -= 0.5 * delta
	else:
		warmth += 0.2 * delta
	
	hunger = clamp(hunger, 0.0, max_value)
	thirst = clamp(thirst, 0.0, max_value)
	warmth = clamp(warmth, 0.0, max_warmth)
	
	hunger_changed.emit(hunger)
	thirst_changed.emit(thirst)
	warmth_changed.emit(warmth)
	
	_check_status()
	
func _check_status():
	var lowest = min(hunger, thirst)
	
	# Critico - Foche aggressive
	if lowest <= critical_threshold:
		if not is_critical:
			is_critical = true
			is_in_danger = true
			status_critical.emit()
			GameManager.trigger_aggressive_seals()
		
	# Pericolo		
	elif lowest <= danger_threshold:
		if not is_in_danger:
			is_in_danger = true
			is_critical = false
			status_danger.emit()
			
	# Sicuro		
	elif lowest > danger_threshold:
		if is_in_danger:
			is_in_danger = false
			is_critical = false
			status_safe.emit()
			
func feed(amount: float):
	hunger += amount
	hunger = clamp(hunger, 0.0, max_value)
	seal_fed.emit("food")
	GameManager.add_satisfaction("food")
	
func give_water(amount: float):
	thirst += amount
	thirst = clamp(thirst, 0.0, max_value)
	seal_fed.emit("water")
	GameManager.add_satisfaction("water")
