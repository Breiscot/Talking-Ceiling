extends Control

@onready var title = $CenterContainer/VBox/TitleLabel
@onready var message = $CenterContainer/VBox/MessageLabel
@onready var info_label = $CenterContainer/VBox/InfoLabel
@onready var restart_btn = $CenterContainer/VBox/RestartButton
@onready var main_menu_btn = $CenterContainer/VBox/MainMenuButton
@onready var quit_btn = $CenterContainer/VBox/QuitButton

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	restart_btn.pressed.connect(_restart)
	main_menu_btn.pressed.connect(_main_menu)
	quit_btn.pressed.connect(_quit)
	
	GameManager.game_over_triggered.connect(_show_lose)
	GameManager.game_won.connect(_show_win)
	
func _show_lose():
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	
	title.text = "GAME OVER"
	title.add_theme_color_override("font_color", Color.RED)
	message.text = "The aggressive Ceilings got you..."
	info_label.text = "You reached level %d / %d\nSatisfaction reached: %.0f%%" % [
		GameManager.current_level,
		GameManager.max_level,
		GameManager.satisfaction
	]
	
func _show_win():
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	
	title.text = "YOU WIN"
	title.add_theme_color_override("font_color", Color.GOLD)
	message.text = "You completed all %d levels!\nCeiling is completely happy!" % GameManager.max_level
	info_label.text = "Satisfaction: 100%"
	
func _restart():
	get_tree().paused = false
	GameManager.restart_game()
	
func _main_menu():
	get_tree().paused = false
	GameManager.is_paused = false
	GameManager.is_game_over = false
	GameManager.has_won = false
	GameManager.current_level = 1
	GameManager.satisfaction = 0.0
	GameManager.difficulty_multiplier = 1.0
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
func _quit():
	get_tree().quit()
