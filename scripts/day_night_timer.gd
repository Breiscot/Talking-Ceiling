extends Node

# Signals
signal day_started
signal night_started
signal time_of_day_changed(is_night: bool)

# Times
@export var day_duration: float = 124.0 # Seconds
@export var night_duration: float = 143.0 # Seconds

# State
var is_night: bool = false
var time_elapsed: float = 0.0
var current_phase: String = "day"

var timer: Timer
var is_running: bool = false

func _ready():
	add_to_group("day_night")
	
	timer = Timer.new()
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	is_night = false
	current_phase = "day"
	GameManager.is_night = false
	time_elapsed = 0.0
	
	print("Day/Night Timer created, Day: %.1f sec, Night: %.1f sec" % [day_duration, night_duration])
	
func start_cycle():
	if not is_running:
		timer.start(1.0)
		is_running = true
		time_elapsed = 0.0
		is_night = false
		current_phase = "day"
		GameManager.is_night = false
		print("Day started. (%.1f seconds)" % day_duration)
		
func stop_cycle():
	if is_running:
		timer.stop()
		is_running = false
		
func _on_timer_timeout():
	time_elapsed += 1.0
	
	if not is_night:
		if time_elapsed >= day_duration:
			is_night = true
			current_phase = "night"
			GameManager.is_night = true
			time_elapsed = 0.0
			night_started.emit()
			time_of_day_changed.emit(true)
	else:
		if time_elapsed >= night_duration:
			is_night = false
			current_phase = "day"
			GameManager.is_night = false
			time_elapsed = 0.0
			day_started.emit()
			time_of_day_changed.emit(false)
			
func get_time_string() -> String:
	var total_seconds = time_elapsed
	var minutes = int(total_seconds / 60)
	var seconds = int(total_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]
	
func get_phase() -> String:
	return "Night" if is_night else "Day"
	
func is_night_time() -> bool:
	return is_night
