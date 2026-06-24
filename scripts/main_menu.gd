extends Control

# Main Menu
@onready var play_btn = $TitleContainer/PlayButton
@onready var settings_btn = $TitleContainer/SettingsButton
@onready var quit_btn = $TitleContainer/QuitButton
@onready var title_container = $TitleContainer

# Difficulty Panel
@onready var diff_panel = $DifficultyPanel
@onready var easy_btn = $DifficultyPanel/DiffCenter/DiffVBox/EasyPanel/EasyVBox/EasyButton
@onready var hard_btn = $DifficultyPanel/DiffCenter/DiffVBox/HardPanel/HardVBox/HardButton
@onready var diff_back_btn = $DifficultyPanel/DiffCenter/DiffVBox/BackButton

# Settings Panel
@onready var settings_panel = $SettingsPanel
@onready var master_slider = $SettingsPanel/SetCenter/SetVBox/MasterVolRow/MasterSlider
@onready var music_slider = $SettingsPanel/SetCenter/SetVBox/MusicVolRow/MusicSlider
@onready var sfx_slider = $SettingsPanel/SetCenter/SetVBox/SFXVolRow/SFXSlider
@onready var sens_slider = $SettingsPanel/SetCenter/SetVBox/SensRow/SensSlider
@onready var set_back_btn = $SettingsPanel/SetCenter/SetVBox/SetBackButton

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Main Menu
	play_btn.pressed.connect(_show_difficulty)
	settings_btn.pressed.connect(_show_settings)
	quit_btn.pressed.connect(_quit)
	
	# Difficulty
	easy_btn.pressed.connect(_start_easy)
	hard_btn.pressed.connect(_start_hard)
	diff_back_btn.pressed.connect(_show_main)
	
	# Settings
	set_back_btn.pressed.connect(_show_main)
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	sens_slider.value_changed.connect(_on_sens_changed)
	
	# Load saved settings
	_load_settings()
	
	# Show Main Menu
	_show_main()
	
func _show_main():
	title_container.visible = true
	diff_panel.visible = false
	settings_panel.visible = false
	
func _show_difficulty():
	title_container.visible = false
	diff_panel.visible = true
	settings_panel.visible = false
	
func _show_settings():
	title_container.visible = false
	diff_panel.visible = false
	settings_panel.visible = true
	
func _start_easy():
	GameManager.set_difficulty("easy")
	_start_game()
	
func _start_hard():
	GameManager.set_difficulty("hard")
	_start_game()
	
func _start_game():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	
func _quit():
	get_tree().quit()
	
func _on_master_changed(value: float):
	var bus_idx = AudioServer.get_bus_index("Master")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))
	_save_settings()
	
func _on_music_changed(value: float):
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))
	_save_settings()
	
func _on_sfx_changed(value: float):
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value / 100.0))
	_save_settings()
	
func _on_sens_changed(value: float):
	GameManager.mouse_sensitivity = value / 5000.0
	_save_settings()
	
func _save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "master", master_slider.value)
	config.set_value("audio", "music", music_slider.value)
	config.set_value("audio", "sfx", sfx_slider.value)
	config.set_value("controls", "sensitivity", sens_slider.value)
	config.save("user://settings.cfg")
	
func _load_settings():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		master_slider.value = config.get_value("audio", "master", 80)
		music_slider.value = config.get_value("audio", "music", 80)
		sfx_slider.value = config.get_value("audio", "sfx", 80)
		sens_slider.value = config.get_value("controls", "sensitivity", 50)
		
		_on_master_changed(master_slider.value)
		_on_music_changed(music_slider.value)
		_on_sfx_changed(sfx_slider.value)
		_on_sens_changed(sens_slider.value)
