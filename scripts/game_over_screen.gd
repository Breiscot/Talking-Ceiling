extends Control

@onready var title = $CenterContainer/VBox/TitleLabel
@onready var message = $CenterContainer/VBox/MessageLabel
@onready var satisfaction_label = $CenterContainer/VBox/SatisfactionLabel
@onready var restart_btn = $CenterContainer/VBox/RestartButton
@onready var quit_btn = $CenterContainer/VBox/QuitButton

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	restart_btn.pressed.connect(_restart)
	quit_btn.pressed.connect(_quit)
	
	GameManager.game_over_triggered.connect(_show_lose)
	GameManager.game_won.connect(_show_win)
	
func _show_lose():
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	
	title.text = "GAME OVER"
	title.add_theme_color_override("font_color", Color.RED)
	message.text = "The aggressive ceilings got you..."
	satisfaction_label.text = "Satisfaction reached: %.0f%%" % GameManager.satisfaction
	
func _show_win():
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	
	title.text = "YOU WIN"
	title.add_theme_color_override("font_color", Color.GREEN)
	message.text = "The ceiling is completely happy!"
	satisfaction_label.text = "Satisfaction: 100%"
	
func _restart():
	get_tree().paused = false
	GameManager.restart_game()
	
func _quit():
	get_tree().quit()
