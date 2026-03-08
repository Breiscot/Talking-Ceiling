extends Node

# Segnali
signal hunger_changed(value: float)
signal thirst_changed(value: float)
signal status_danger
signal status_critical
signal status_safe
signal seal_fed(type: String)

# Bisogni
var hunger: float = 100.0
var thirst: float = 100.0
var max_value: float = 100.0

@export var hunger_decay: float = 2.0
@export var thirst_decay: float = 2.5

@export var danger_threshold: float = 20.0
@export var critical_threshold: float = 5.0

var is_in_danger: bool = false
var is_critical: bool = false
	

func _process(delta):
	if GameManager.is_paused or GameManager.is_game_over:
		return
		
	# Diminuisci bisogni
	hunger -= hunger_decay * delta
	thirst -= thirst_decay * delta
	
	hunger = clamp(hunger, 0.0, max_value)
	thirst = clamp(thirst, 0.0, max_value)
	
	hunger_changed.emit(hunger)
	thirst_changed.emit(thirst)
	
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
