extends Node3D

# Segnali
signal night_started
signal day_ended
signal time_updated(normalized_time: float)

# Impostazioni
@export var day_duration_seconds: float = 300.0 # 5 minuti
@export_range(0.0, 1.0) var night_start_time: float = 0.75

# Colori cielo
@export var dawn_color: Color = Color(1.0, 0.6, 0.3)
@export var noon_color: Color = Color(1.0, 0.95, 0.8)
@export var dusk_color: Color = Color(1.0, 0.4, 0.2)
@export var night_color: Color = Color(0.1, 0.1, 0.3)

# Altro
@export var sun_light: DirectionalLight3D
@export var world_environment: WorldEnvironment

# Stato
var current_time: float = 0.0 # 0 é Alba, 1 é fine giornata
var is_night: bool = false
var can_sleep: bool = false
var day_has_ended: bool = false

# Intensità del sole
var max_sun_intensity: float = 1.2
var min_sun_intensity: float = 0.05

func _ready():
	GameManager.day_started.connect(_on_new_day)
	current_time = 0.0
	
func _process(delta):
	if GameManager.is_paused or GameManager.is_game_over:
		return
		
	# Avanza il tempo
	current_time += delta / day_duration_seconds
	current_time = clamp(current_time, 0.0, 1.2)
	
	# Aggiorna sole
	_update_sun()
	
	# Aggiorna env
	_update_environment()
	
	# Emetti segnale tempo
	time_updated.emit(current_time)
	
	# Controlla la notte
	if current_time >= night_start_time and not is_night:
		is_night = true
		can_sleep = true
		night_started.emit()
		
	# Fine giornata
	if current_time >= 1.0 and not day_has_ended:
		day_has_ended = true
		day_ended.emit()
		_force_end_day()
		
func _update_sun():
	if not sun_light:
		return
		
	# Spostamento sole (da est a ovest)
	var sun_angle = lerp(-30.0, 210.0, current_time)
	sun_light.rotation_degrees = Vector3(sun_angle, -30.0, 0.0)
	
	# Intensità sole
	var intensity_curve: float
	if current_time < 0.25:
		intensity_curve = lerp(0.1, max_sun_intensity, current_time / 0.25)
	elif current_time < 0.75:
		intensity_curve = max_sun_intensity
	else:
		intensity_curve = lerp(max_sun_intensity, min_sun_intensity, (current_time - 0.75) / 0.25)
		
	sun_light.light_energy = intensity_curve
	
	# Colore sole
	var sun_color: Color
	if current_time < 0.15:
		sun_color = dawn_color
	elif current_time < 0.35:
		sun_color = dawn_color.lerp(noon_color, (current_time - 0.15) / 0.2)
	elif current_time < 0.65:
		sun_color = noon_color
	elif current_time < 0.8:
		sun_color = noon_color.lerp(dusk_color, (current_time - 0.65) / 0.15)
	else:
		sun_color = dusk_color.lerp(night_color, (current_time - 0.8) / 0.2)
		
	sun_light.light_color = sun_color
	
func _update_environment():
	if not world_environment or not world_environment.environment:
		return
		
	var env = world_environment.environment
	
	# Aggiorna colore cielo
	if current_time > 0.75:
		var night_factor = (current_time - 0.75) / 0.25
		env.ambient_light_energy = lerp(0.5, 0.1, night_factor)
	
	
	
	
