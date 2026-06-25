extends Control

# Buttons
@onready var resume_btn = $CenterContainer/VBox/ResumeButton
@onready var settings_btn = $CenterContainer/VBox/SettingsButton
@onready var restart_btn = $CenterContainer/VBox/RestartButton
@onready var main_menu_btn = $CenterContainer/VBox/MainMenuButton
@onready var quit_btn = $CenterContainer/VBox/QuitButton

# Pause Settings
@onready var pause_settings = $PauseSettings
@onready var pause_buttons = $CenterContainer

# Sliders
@onready var p_master = $PauseSettings/SetCenter/SetVBox/MasterVolRow/MasterSlider
@onready var p_music = $PauseSettings/SetCenter/SetVBox/MusicVolRow/MusicSlider
@onready var p_sfx = $PauseSettings/SetCenter/SetVBox/SFXVolRow/SFXSlider
@onready var p_sens = $PauseSettings/SetCenter/SetVBox/SensRow/SensSlider
@onready var p_fullscreen = $PauseSettings/SetCenter/SetVBox/FullscreenRow/FullscreenCheck
@onready var p_back = $PauseSettings/SetCenter/SetVBox/SetBackButton

func _ready():
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	resume_btn.pressed.connect(_resume)
	settings_btn.pressed.connect(_settings)
	restart_btn.pressed.connect(_restart)
	main_menu_btn.pressed.connect(_main_menu)
	quit_btn.pressed.connect(_quit)
	
	p_back.pressed.connect(_hide_pause_settings)
	
	p_master.value_changed.connect(func(v): _set_bus("Master", v))
	p_music.value_changed.connect(func(v): _set_bus("Music", v))
	p_sfx.value_changed.connect(func(v): _set_bus("SFX", v))
	p_sens.value_changed.connect(func(v): GameManager.mouse_sensitivity = v / 5000.0)
	p_fullscreen.toggled.connect(_on_fullscreen_toggled)
	
	if pause_settings:
		pause_settings.visible = false
		
func _on_fullscreen_toggled(enabled: bool):
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_save_settings()
		
func _settings():
	pause_buttons.visible = false
	pause_settings.visible = true
	_load_pause_settings()
	
func _hide_pause_settings():
	pause_buttons.visible = true
	pause_settings.visible = false
	_save_settings()
	
func _set_bus(bus_name: String, value: float):
	var idx = AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(value / 100.0))
		
func _load_pause_settings():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		p_master.value = config.get_value("audio", "master", 80)
		p_music.value = config.get_value("audio", "music", 80)
		p_sfx.value = config.get_value("audio", "sfx", 80)
		p_sens.value = config.get_value("controls", "sensitivity", 50)
		p_fullscreen.button_pressed = config.get_value("video", "fullscreen", false)
		
func _save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "master", p_master.value)
	config.set_value("audio", "music", p_music.value)
	config.set_value("audio", "sfx", p_sfx.value)
	config.set_value("controls", "sensitivity", p_sens.value)
	config.set_value("video", "fullscreen", p_fullscreen.button_pressed)
	config.save("user://settings.cfg")
	
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
	
func _main_menu():
	get_tree().paused = false
	GameManager.restart_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
func _quit():
	get_tree().quit()
