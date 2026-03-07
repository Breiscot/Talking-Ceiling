extends Node

# Segnali
signal hunger_changed(value: float)
signal thirst_changed(value: float)
signal status_danger
signal status_critical
signal status_safe
signal seal_fed(type: String)

# Bisogni
@export var max_hunger: float = 100.0
@export var max_thirst: float = 100.0

var hunger: float = 100.0
var thirst: float = 100.0

@export var hunger_decay_per_second: float = 2.0
@export var thirst_decay_per_second: float = 2.5

@export var danger_threshold: float = 20.0
@export var critical_threshold: float = 5.0

var is_in_danger: bool = false
var is_critical: bool = false
var difficulty_multiplier: float = 1.0

var hunger_percentage: float:
	get:
		return hunger / max_hunger
		
var thirst_percentage: float:
	get:
		return thirst / max_thirst
		
func _ready():
	GameManager.difficulty_changed.connect(_on_difficulty_changed)
	GameManager.day_started.connect(_on_day_started)
	
func _process(delta):
	if GameManager.is_paused or GameManager.is_game_over:
		return
		
	# Diminuisci bisogni
	var decay = difficulty_multiplier * delta
	
	hunger -= hunger_decay_per_second * decay
	thirst -= thirst_decay_per_second * decay
	
	hunger = clamp(hunger, 0.0, max_hunger)
	thirst = clamp(thirst, 0.0, max_thirst)
	
	# Debug
	if Engine.get_frames_drawn() % 120 == 0:
		print("Hunger: %.1f | Thirst: %.1f | Difficulty: %.2f" % [hunger, thirst, difficulty_multiplier])
	
	# Emetti segnali aggiornamento
	hunger_changed.emit(hunger)
	thirst_changed.emit(thirst)
	
	# Controlla stato
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
	hunger = clamp(hunger, 0.0, max_hunger)
	seal_fed.emit("food")
	
func give_water(amount: float):
	thirst += amount
	thirst = clamp(thirst, 0.0, max_thirst)
	seal_fed.emit("water")

func get_most_urgent_need() -> String:
	if hunger <= thirst:
		return "food"
	return "water"
	
func _on_difficulty_changed(multiplier: float):
	difficulty_multiplier = multiplier
	
func _on_day_started(_day: int):
	pass
