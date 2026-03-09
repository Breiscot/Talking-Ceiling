extends Control

@onready var hunger_bar: ProgressBar = $NeedsPanel/VBoxContainer/HungerBar
@onready var thirst_bar: ProgressBar = $NeedsPanel/VBoxContainer/ThirstBar
@onready var hunger_label: Label = $NeedsPanel/VBoxContainer/HungerLabel
@onready var thirst_label: Label = $NeedsPanel/VBoxContainer/ThirstLabel
@onready var fish_label: Label = $InventoryPanel/HBoxContainer/PanelContainer/FishLabel
@onready var water_label: Label = $InventoryPanel/HBoxContainer/PanelContainer2/WaterLabel
@onready var warning_panel: PanelContainer = $WarningPanel
@onready var warning_label: Label = $WarningPanel/WarningLabel
@onready var interaction_label: Label = $InteractionPrompt
@onready var satisfaction_bar: ProgressBar = $SatisfactionPanel/VBoxContainer/SatisfactionBar
@onready var satisfaction_label: Label = $SatisfactionPanel/VBoxContainer/SatisfactionLabel

# Colori barre
var color_safe: Color = Color(0.2, 0.8, 0.2)
var color_warning: Color = Color(1.0, 0.8, 0.0)
var color_danger: Color = Color(1.0, 0.2, 0.2)

var seal_needs: Node = null
var inventory: Node = null
var player_interaction: Node = null

func _ready():
	await get_tree().process_frame
	
	seal_needs = GameManager.seal_needs
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		inventory = player.get_node_or_null("PlayerInventory")
		player_interaction = player.get_node_or_null("PlayerInteraction")
	
	# Connette segnali
	if seal_needs:
		seal_needs.hunger_changed.connect(_on_hunger)
		seal_needs.thirst_changed.connect(_on_thirst)
		seal_needs.status_danger.connect(func(): _show_warning("The ceiling needs care!", Color.YELLOW))
		seal_needs.status_critical.connect(func(): _show_warning("AGGRESSIVE SEALS INCOMING...", Color.RED))
		seal_needs.status_safe.connect(func(): warning_panel.visible = false)
		
	# Connette inventario
	if inventory:
		inventory.inventory_changed.connect(_on_inventory)
		
	# Connette Soddisfazione
	GameManager.satisfaction_changed.connect(_on_satisfaction)
	
	if warning_panel:
		warning_panel.visible = false
	if interaction_label:
		interaction_label.visible = false
		
func _process(_delta):
	if player_interaction and interaction_label:
		if player_interaction.current_target:
			interaction_label.visible = true
			if player_interaction.current_target.has_method("get_interaction_text"):
				interaction_label.text = player_interaction.current_target.get_interaction_text()
		else:
			interaction_label.visible = false
		
func _on_hunger(value: float):
	if hunger_bar:
		hunger_bar.value = value
		hunger_bar.modulate = _bar_color(value / 100.0)
	if hunger_label:
		hunger_label.text = "Hunger of the ceiling:"
		
func _on_thirst(value: float):
	if thirst_bar:
		thirst_bar.value = value
		thirst_bar.modulate = _bar_color(value / 100.0)
	if thirst_label:
		thirst_label.text = "Thirst of the ceiling:"
		
func _on_inventory(fish: int, water: int):
	if fish_label:
		fish_label.text = "Fish x%d" % fish
	if water_label:
		water_label.text = "Water x%d" % water
		
func _on_satisfaction(value: float):
	if satisfaction_bar:
		satisfaction_bar.value = value
		satisfaction_bar.modulate = Color.GREEN if value > 50 else Color.YELLOW
	if satisfaction_label:
		satisfaction_label.text = "Satisfaction of the ceiling: %.0f%%" % value
		
func _show_warning(text: String, color: Color):
	if warning_panel:
		warning_panel.visible = true
	if warning_label:
		warning_label.text = text
		warning_label.modulate = color
		
func _bar_color(pct: float) -> Color:
	if pct > 0.5:
		return Color.GREEN
	elif pct > 0.2:
		return Color.YELLOW
	return Color.RED
