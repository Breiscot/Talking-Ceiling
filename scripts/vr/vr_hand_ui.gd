extends Node3D

@export var is_left_hand: bool = true

@onready var screen: MeshInstance3D = $Screen
@onready var viewport: SubViewport = $SubViewport

# Mano Sinistra
var fish_label: Label = null
var water_label: Label = null

# Mano Destra
var hunger_label: Label = null
var thirst_label: Label = null
var satisfaction_label: Label = null

var inventory = null
var is_visible_ui: bool = false

# Soglia altezza per mostrare UI
var show_threshold_y: float = 1.2

func _ready():
	# Applica viewport come texture allo schermo
	var mat = StandardMaterial3D.new()
	mat.albedo_texture = viewport.get_texture()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = mat
	
	# Nascondi
	screen.visible = false
	
	await get_tree().create_timer(0.5).timeout
	_find_references()
	
func _find_references():
	if is_left_hand:
		fish_label = viewport.get_node_or_null("Control/VBoxContainer/FishRow/FishLabel")
		water_label = viewport.get_node_or_null("Control/VBoxContainer/WaterRow/WaterLabel")
		
		var fish_btn = viewport.get_node_or_null("Control/VBoxContainer/FishRow/FishBtn")
		var water_btn = viewport.get_node_or_null("Control/VBoxContainer/WaterRow/WaterBtn")
		
		if fish_btn:
			fish_btn.pressed.connect(_take_fish_from_inventory)
		if water_btn:
			water_btn.pressed.connect(_take_water_from_inventory)
			
		# Trova inventario
		var player = get_tree().get_first_node_in_group("player")
		if player:
			inventory = player.get_node_or_null("PlayerInventory")
			
		if inventory:
			inventory.inventory_changed.connect(_on_inventory_changed)
			
	else:
		hunger_label = viewport.get_node_or_null("Control/VBoxContainer/HungerLabel")
		thirst_label = viewport.get_node_or_null("Control/VBoxContainer/ThirstLabel")
		satisfaction_label = viewport.get_node_or_null("Control/VBoxContainer/SatisfactionLabel")
		
		if GameManager.seal_needs:
			GameManager.seal_needs.hunger_changed.connect(_on_hunger)
			GameManager.seal_needs.thirst_changed.connect(_on_thirst)
			
		GameManager.satisfaction_changed.connect(_on_satisfaction)
		
func _process(_delta):
	# Controlla altezza della mano per mostrare UI
	var hand_y = global_position.y
	var camera = get_tree().get_first_node_in_group("xr_camera")
	
	if camera:
		var camera_y = camera.global_position.y
		var relative_y = hand_y - camera_y
		
		var should_show = relative_y > -0.1
		
		if should_show != is_visible_ui:
			is_visible_ui = should_show
			screen.visible = should_show
			
func _on_inventory_changed(fish: int, water: int):
	if fish_label:
		fish_label.text = "Fish: %d" % fish
	if water_label:
		water_label.text = "Water: %d" % water
		
func _on_hunger(value: float):
	if hunger_label:
		hunger_label.text = "Hunger: %.0f%%" % value
		hunger_label.modulate = _bar_color(value / 100.0)
		
func _on_thirst(value: float):
	if thirst_label:
		thirst_label.text = "Thirst: %.0f%%" % value
		thirst_label.modulate = _bar_color(value / 100.0)
		
func _on_satisfaction(value: float):
	if satisfaction_label:
		satisfaction_label.text = "Satisfaction: %.0f%%" % value
		
func _take_fish_from_inventory():
	if inventory and inventory.fish > 0:
		_spawn_item_in_hand("fish")
		
func _take_water_from_inventory():
	if inventory and inventory.water > 0:
		_spawn_item_in_hand("water")
		
func _spawn_item_in_hand(type: String):
	var left_ctrl = get_tree().get_nodes_in_group("left_controller")
	if left_ctrl.size() == 0:
		return
		
	var controller = left_ctrl[0]
	
	# Crea oggetto fisico
	var item_scene
	if type == "fish":
		item_scene = preload("res://scenes/collectibles/fish_collectible.tscn")
		inventory.use_fish()
	else:
		item_scene = preload("res://scenes/collectibles/water_collectible.tscn")
		inventory.use_water()
		
	var item = item_scene.instantiate()
	get_tree().current_scene.add_child(item)
	item.global_position = controller.global_position
	
	if controller.has_method("force_grab"):
		controller.force_grab(item)
		
func _bar_color(pct: float) -> Color:
	if pct > 0.5: return Color.GREEN
	elif pct > 0.2: return Color.YELLOW
	return Color.RED
