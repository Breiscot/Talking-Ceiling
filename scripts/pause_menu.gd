extends Control

@onready var resume_btn = $CenterContainer/VBox/ResumeButton
@onready var restart_btn = $CenterContainer/VBox/RestartButton
@onready var quit_btn = $CenterContainer/VBox/QuitButton

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	resume_btn.pressed.connect(_resume)
	restart_btn.pressed.connect(_restart)
	quit_btn.pressed.connect(_quit)
	
func _input(event):
	if event.is_action_pressed("pause"):
		if GameManager.is_game_over or GameManager.has_won:
			return
			
		if visible:
			_resume()
		else:
			_pause()
			
		get_viewport().set_input_as_handled()
			
func _pause():
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func _resume():
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _restart():
	visible = false
	get_tree().paused = false
	GameManager.restart_game()
	
func _quit():
	get_tree().quit()
