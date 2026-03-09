extends Node

# Segnali
signal game_over_triggered
signal game_won
signal aggressive_seals_triggered
signal satisfaction_changed(value: float)

# Impostazioni
@export var max_days: int = 5
@export var needs_multiplier_per_day: float = 1.25

# Stato
var is_game_over: bool = false
var has_won: bool = false
var is_paused: bool = false

var seal: Node3D = null
var seal_needs: Node = null

var satisfaction: float = 0.0
var max_satisfaction: float = 100.0
var satisfaction_per_fish: float = 8.0
var satisfaction_per_water: float = 8.0
var satisfaction_decay: float = 0.3

func _ready():
	print("Game Manager iniziato.")
	
func _process(delta):
	if is_game_over or has_won:
		return
		
	# la soddisfazione cala
	satisfaction -= satisfaction_decay * delta
	satisfaction = clamp(satisfaction, 0.0, max_satisfaction)
	satisfaction_changed.emit(satisfaction)
	
	if satisfaction >= 99.5:
		satisfaction = max_satisfaction
		satisfaction_changed.emit(satisfaction)
		win_game()
		
func add_satisfaction(type: String):
	if is_game_over or has_won:
		return
		
	if type == "food":
		satisfaction += satisfaction_per_fish
	elif type == "water":
		satisfaction += satisfaction_per_water
		
	satisfaction = clamp(satisfaction, 0.0, max_satisfaction)
	satisfaction_changed.emit(satisfaction)
	
	if satisfaction >= max_satisfaction:
		win_game()
		
func trigger_aggressive_seals():
	if is_game_over:
		return
	aggressive_seals_triggered.emit()
	
func trigger_game_over():
	if is_game_over:
		return
	is_game_over = true
	is_paused = true
	game_over_triggered.emit()
	
func win_game():
	if has_won:
		return
	has_won = true
	is_paused = true
	game_won.emit()
	
func restart_game():
	is_paused = false
	is_game_over = false
	has_won = false
	satisfaction = 0.0
	get_tree().reload_current_scene()
