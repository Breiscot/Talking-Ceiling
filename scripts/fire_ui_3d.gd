extends Node3D

@onready var billboard: Node3D = $Billboard
@onready var fire_bar: MeshInstance3D = $Billboard/FireBar
@onready var fire_bar_bg: MeshInstance3D = $Billboard/FireBarBG
@onready var fire_percent: Label3D = $Billboard/FirePercent
@onready var fire_label: Label3D = $Billboard/FireLabel

var is_visible: bool = false
var target_alpha: float = 0.0
var current_alpha: float = 0.0

var bar_mat: StandardMaterial3D
var bar_bg_mat: StandardMaterial3D

var fire_level: float = 0.0

var fade_material: StandardMaterial3D
var label_fade_material: StandardMaterial3D

func _ready():
	bar_mat = StandardMaterial3D.new()
	bar_mat.albedo_color = Color(1.0, 0.5, 0.0)
	bar_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	bar_bg_mat = StandardMaterial3D.new()
	bar_bg_mat.albedo_color = Color(0.2, 0.2, 0.2)
	bar_bg_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	if fire_bar:
		fire_bar.material_override = bar_mat
	if fire_bar_bg:
		fire_bar_bg.material_override = bar_bg_mat
		
	fade_material = StandardMaterial3D.new()
	fade_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	label_fade_material = StandardMaterial3D.new()
	label_fade_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		
	visible = false
	
	await get_tree().process_frame
	_connect_to_day_night()
	
func _connect_to_day_night():
	var day_night = get_tree().get_first_node_in_group("day_night")
	if day_night:
		if day_night.has_signal("night_started"):
			day_night.night_started.connect(_show)
		if day_night.has_signal("day_started"):
			day_night.day_started.connect(_hide)
			
		if day_night.has_method("is_night_time"):
			if day_night.is_night_time():
				_show()
			else:
				_hide()
	else:
		print("FireUI: Cycle day/night not found.")
		
func _process(delta):
	_update_fire_bar()
	
	# Fade In/Out
	current_alpha = move_toward(current_alpha, target_alpha, delta * 3.0)
	
	_apply_alpha(current_alpha)
	
	if current_alpha > 0.01:
		visible = true
	else:
		visible = false
		
func _apply_alpha(alpha: float):
	if fire_bar and fire_bar.material_override:
		var mat = fire_bar.material_override as StandardMaterial3D
		var color = mat.albedo_color
		color.a = alpha
		mat.albedo_color = color
		
	if fire_bar_bg and fire_bar_bg.material_override:
		var mat = fire_bar_bg.material_override as StandardMaterial3D
		var color = mat.albedo_color
		color.a = alpha
		mat.albedo_color = color
		
	if fire_percent:
		var color = fire_percent.modulate
		color.a = alpha
		fire_percent.modulate = color
	if fire_label:
		var color = fire_label.modulate
		color.a = alpha
		fire_label.modulate = color
		
func _update_fire_bar():
	var campfire = GameManager.campfire
	if not campfire:
		print("FireUI: campfire is null, wait...")
		campfire = get_tree().get_first_node_in_group("campfire")
		if campfire:
			print("FireUI: campfire founded.")
			GameManager.campfire = campfire
		else:
			return
		
	if not campfire.has_method("get_fire_level"):
		print("FireUI: campfire don't have get_fire_level()")
		return
		
	fire_level = campfire.get_fire_level()
	
	var percentage = fire_level / 100.0
	percentage = clamp(percentage, 0.0, 1.0)
	
	if fire_bar:
		fire_bar.scale.x = max(percentage, 0.01)
		
		if percentage > 0.5:
			bar_mat.albedo_color = Color(1.0, 0.8, 0.0)
		elif percentage > 0.2:
			bar_mat.albedo_color = Color(1.0, 0.5, 0.0)
		else:
			bar_mat.albedo_color = Color(1.0, 0.2, 0.0)
			
	if fire_percent:
		fire_percent.text = "%.0f%%" % (percentage * 100)
		
func _show():
	target_alpha = 1.0
	
func _hide():
	target_alpha = 0.0
	
func get_fire_level() -> float:
	return fire_level
