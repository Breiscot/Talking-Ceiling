extends Control

@onready var title_label = $CenterContainer/VBox/LevelCompleteTitle
@onready var info_label = $CenterContainer/VBox/LevelInfoLabel
@onready var difficulty_label = $CenterContainer/VBox/DifficultyLabel
@onready var continue_btn = $CenterContainer/VBox/ContinueButton

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	continue_btn.pressed.connect(_on_continue)
	GameManager.level_completed.connect(_on_level_completed)
	
func _on_level_completed(level: int):
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	
	if level >= GameManager.max_level:
		title_label.text = "ALL LEVELS COMPLETE!"
		title_label.add_theme_color_override("font_color", Color.GOLD)
		info_label.text = "You completed all %d levels!" % GameManager.max_level
		difficulty_label.text = "You are the ultimate seal caretaker!"
		continue_btn.visible = false
	else:
		title_label.text = "LEVEL %d COMPLETE!" % level
		title_label.add_theme_color_override("font_color", Color.GREEN)
		info_label.text = "Get ready for level %d..." % (level + 1)
		
		# View next difficulty
		var next_diff = 1.0 + level * 0.2
		var next_hunger = 2.0 + level * 0.3
		var next_thirst = 2.5 + level * 0.35
		difficulty_label.text = "Difficulty: x%.1f | Hunger decay: %.1f | Thirst decay: %.1f" % [next_diff, next_hunger, next_thirst]
		continue_btn.visible = true
		
	# Animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
func _on_continue():
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameManager.advance_to_next_level()
