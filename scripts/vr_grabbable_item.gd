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
	
