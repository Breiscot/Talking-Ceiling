extends Node

# Segnali
signal day_started(day_number: int)
signal game_over_triggered
signal game_won
signal aggressive_seals_triggered(count: int)
signal difficulty_changed(multiplier: float)

# Impostazioni
@export var max_days: int = 5
@export var needs_multiplier_per_day: float = 1.25

# Stato
var current_day: int = 1
var is_game_over: bool = false
var has_won: bool = false
var is_paused: bool = false

var seal: Node3D = null
var seal_needs: Node = null
var day_night_cycle: Node = null
var resource_spawner: Node = null
var hud: Control = null
var game_over_screen: Control = null

func _ready():
	print("Game Manager iniziato.")
	
func start_game():
	current_day = 1
	is_game_over = false
	has_won = false
	is_paused = false
	start_day(1)
	
func start_day(day: int):
	current_day = day
	print("Giorno %d iniziato." % current_day)
	
	var multiplier = pow(needs_multiplier_per_day, current_day - 1)
	difficulty_changed.emit(multiplier)
	
	# Segnala nuovo giorno
	day_started.emit(current_day)
	
func advance_to_next_day():
	if current_day >= max_days:
		win_game()
	else:
		start_day(current_day + 1)
		
func trigger_aggressive_seals():
	var count = 1 + (current_day - 1)
	aggressive_seals_triggered.emit(count)
	
func trigger_game_over():
	if is_game_over:
		return
	is_game_over = true
	is_paused = true
	game_over_triggered.emit()
	
func win_game():
	has_won = true
	is_paused = true
	game_won.emit()
	
func restart_game():
	is_paused = false
	get_tree().reload_current_scene()
