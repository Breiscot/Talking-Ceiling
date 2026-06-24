extends Node

# Segnali
signal game_over_triggered
signal game_won
signal aggressive_seals_triggered
signal satisfaction_changed(value: float)
signal level_changed(level: int)
signal level_completed(level: int)

# Impostazioni
@export var max_days: int = 5
@export var needs_multiplier_per_day: float = 1.25

# Stato
var is_game_over: bool = false
var has_won: bool = false
var is_paused: bool = false

# Seal
var seal: Node3D = null
var seal_needs: Node = null

# Levels
var current_level: int = 1
var max_level: int = 15

# Satisfaction
var satisfaction: float = 0.0
var max_satisfaction: float = 100.0
var base_satisfaction_per_fish: float = 8.0
var base_satisfaction_per_water: float = 8.0
var satisfaction_decay: float = 0.3

# Difficulty for level
var difficulty_multiplier: float = 1.0

# Difficulty
var difficulty: String = "hard"
var difficulty_presets = {
	"easy": {
		"base_hunger_decay": 1.2,
		"base_thirst_decay": 1.5,
		"hunger_increase_per_level": 0.1,
		"thirst_increase_per_level": 0.12,
		"base_satisfaction_per_fish": 12.0,
		"base_satisfaction_per_water": 12.0,
		"satisfaction_decay": 0.15,
		"difficulty_increase_per_level": 0.08
	},
	"hard": {
		"base_hunger_decay": 2.0,
		"base_thirst_decay": 2.5,
		"hunger_increase_per_level": 0.3,
		"thirst_increase_per_level": 0.35,
		"base_satisfaction_per_fish": 8.0,
		"base_satisfaction_per_water": 8.0,
		"satisfaction_decay": 0.3,
		"difficulty_increase_per_level": 0.2
	}
}

# Settings
var mouse_sensitivity: float = 0.002

func _ready():
	print("Game Manager iniziato.")
	
func _process(delta):
	if is_game_over or has_won or is_paused:
		return
		
	# Decay satisfaction
	satisfaction -= satisfaction_decay * difficulty_multiplier * delta
	satisfaction = clamp(satisfaction, 0.0, max_satisfaction)
	satisfaction_changed.emit(satisfaction)
	
	if satisfaction >= 99.5:
		satisfaction = max_satisfaction
		satisfaction_changed.emit(satisfaction)
		_complete_level()
		
func add_satisfaction(type: String):
	if is_game_over or has_won or is_paused:
		return
		
	var level_reduction = 1.0 / (1.0 + (current_level - 1) * 0.15)
		
	if type == "food":
		satisfaction += base_satisfaction_per_fish * level_reduction
	elif type == "water":
		satisfaction += base_satisfaction_per_water * level_reduction
		
	satisfaction = clamp(satisfaction, 0.0, max_satisfaction)
	satisfaction_changed.emit(satisfaction)
	
func _complete_level():
	is_paused = true
	print("Level %d completed." % current_level)
	level_completed.emit(current_level)
	
	if current_level >= max_level:
		win_game()
		
func advance_to_next_level():
	current_level += 1
	satisfaction = 0.0
	
	var preset = difficulty_presets[difficulty]
	
	# Increase difficulty in base on preset
	difficulty_multiplier = 1.0 + (current_level - 1) * preset.difficulty_increase_per_level
	
	# Update decay hunger/thirst of Ceiling
	if seal_needs:
		seal_needs.hunger_decay = preset.base_hunger_decay + (current_level - 1) * preset.hunger_increase_per_level
		seal_needs.thirst_decay = preset.base_thirst_decay + (current_level - 1) * preset.thirst_increase_per_level
		
	is_paused = false
	satisfaction_changed.emit(satisfaction)
	level_changed.emit(current_level)
	print("Level %d. Difficulty: x%.1f" % [current_level, difficulty_multiplier])

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
	current_level = 1
	satisfaction = 0.0
	difficulty_multiplier = 1.0
	get_tree().reload_current_scene()

func set_difficulty(diff: String):
	difficulty = diff
	var preset = difficulty_presets[diff]
	
	base_satisfaction_per_fish = preset.base_satisfaction_per_fish
	base_satisfaction_per_water = preset.base_satisfaction_per_water
	satisfaction_decay = preset.satisfaction_decay
	
	print("Difficulty: %s" % diff.to_upper())
	
