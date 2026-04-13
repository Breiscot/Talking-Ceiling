extends RigidBody3D

enum ItemType { FISH, WATER }
@export var item_type: ItemType = ItemType.FISH
@export var amount: int = 1

var is_held: bool = false
var holding_controller = null

func _ready():
	add_to_group("grabbable")
	
func grab(controller):
	is_held = true
	holding_controller = controller
	
	# Disabilita fisica mentre é in mano
	freeze = true
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
func release():
	is_held = false
	holding_controller = null
	
	# Riattiva fisica
	freeze = false
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	
func get_item_type() -> String:
	if item_type == ItemType.FISH:
		return "fish"
	return "water"
