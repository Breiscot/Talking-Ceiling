extends Control

@onready var day_label: Label = $MarginContainer/VBoxContainer/DayLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel
@onready var phase_label: Label = $MarginContainer/VBoxContainer/PhaseLabel

@onready var hunger_bar: ProgressBar = $NeedsPanel/VBoxContainer/HungerBar
@onready var thirst_bar: ProgressBar = $NeedsPanel/VBoxContainer/ThirstBar
@onready var hunger_label: Label = $NeedsPanel/VBoxContainer/HungerLabel
@onready var thirst_label: Label = $NeedsPanel/VBoxContainer/ThirstLabel

@onready var fish_label: Label = $InventoryPanel/VBoxContainer/FishLabel
@onready var water_label: Label = $InventoryPanel/VBoxContainer/WaterLabel

@onready var warning_panel: PanelContainer = $WarningPanel
@onready var warning_label: Label = $WarningPanel/WarningLabel

@onready var interaction_label: Label = $InteractionPrompt

# Colori barre
var color_safe: Color = Color(0.2, 0.8, 0.2)
var color_warning: Color = Color(1.0, 0.8, 0.0)
var color_danger: Color = Color(1.0, 0.2, 0.2)

var seal_needs: Node = null
var day_night: Node = null
var inventory: Node = null

func _ready():
	await get_tree().process_frame
	
	seal_needs = GameManager.seal_needs
	day_night = get_tree().get_first_node_in_group("day_night")
	inventory = get_tree().get_first_node_in_group("player_inventory")
	
	# Connette segnali
	if seal_needs:
		seal_needs.hunger_changed.connect(_on_hunger_changed)
		seal_needs.thirst_changed.connect(_on_thirst_changed)
		seal_needs.status_danger.connect(_on_danger)
		seal_needs.status_critical.connect(_on_critical)
		seal_needs.status_safe.connect(_on_safe)
		
	if inventory:
		inventory.inventory_changed.connect(_on_inventory_changed)
		
	GameManager.day_started.connect(_on_day_started)
	
	if warning_panel:
		warning_panel.visible = false
		
func _process(_delta):
	_update_time_display()
	
func _update_time_display():
	if not day_night:
		return
		
	if time_label:
		time_label.text = day_night.get_time_string()
		
	if phase_label:
		phase_label.text = day_night.get_phase_name()
		
func _on_day_started(day: int):
	if day_label:
		day_label.text = "Day %d / %d" % [day, GameManager.max_days]
		
	if warning_panel:
		warning_panel.visible = false
		
func _on_hunger_changed(value: float):
	if hunger_bar:
		hunger_bar.value = value
		hunger_bar.modulate = _get_bar_color(value / 100.0)
	if hunger_label:
		hunger_label.text = "Hunger: %.0f%%" % value
		
func _on_thirst_changed(value: float):
	if thirst_bar:
		thirst_bar.value = value
		thirst_bar.modulate = _get_bar_color(value / 100.0)
	if thirst_label:
		thirst_label.text = "Thirst: %.0f%%" % value
		
func _on_inventory_changed(fish: int, water: int):
	if fish_label:
		fish_label.text = "Fish x%d" % fish
	if water_label:
		water_label.text = "Water x%d" % water
		
func _on_danger():
	if warning_panel:
		warning_panel.visible = true
	if warning_label:
		warning_label.text = "The ceiling needs care!"
		warning_label.modulate = color_warning
		
func _on_critical():
	if warning_panel:
		warning_panel.visible = true
	if warning_label:
		warning_label.text = "It's too late, the big seals are coming..."
		warning_label.modulate = color_danger
		
func _on_safe():
	if warning_panel:
		warning_panel.visible = false
		
func _get_bar_color(percentage: float) -> Color:
	if percentage > 0.5:
		return color_safe.lerp(Color.WHITE, (percentage - 0.5) * 2)
	elif percentage > 0.2:
		return color_warning.lerp(color_safe, (percentage - 0.2) / 0.3)
	else:
		return color_danger.lerp(color_warning, percentage / 0.2)
