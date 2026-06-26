extends Node

# Segnali
signal inventory_changed(fish: int, water: int, wood: int)
signal item_collected(type: String, amount: int)
signal inventory_full(type: String)

# Inventario
var fish: int = 0
var water_bottles: int = 0
var wood: int = 0
var max_wood: int = 15

@export var max_fish: int = 10
@export var max_water: int = 10

func _ready():
	add_to_group("player_inventory")

func add_fish(amount: int = 1) -> bool:
	if fish >= max_fish:
		inventory_full.emit("fish")
		return false
		
	fish = min(fish + amount, max_fish)
	inventory_changed.emit(fish, water_bottles, wood)
	item_collected.emit("fish", amount)
	print("+%d fish. total: %d" % [amount, fish])
	return true
	
func add_water(amount: int = 1) -> bool:
	if water_bottles >= max_water:
		inventory_full.emit("water")
		return false
		
	water_bottles = min(water_bottles + amount, max_water)
	inventory_changed.emit(fish, water_bottles, wood)
	item_collected.emit("water", amount)
	print("+%d water. total: %d" % [amount, water_bottles])
	return true
	
func add_wood(amount: int = 1) -> bool:
	if wood >= max_wood:
		inventory_full.emit("wood")
		return false
	wood = min(wood + amount, max_wood)
	inventory_changed.emit(fish, water_bottles, wood)
	item_collected.emit("wood", amount)
	print("+%d wood. total: %d" % [amount, wood])
	return true
	
func use_fish() -> bool:
	if fish <= 0:
		return false
	fish -= 1
	inventory_changed.emit(fish, water_bottles)
	return true
	
func use_water() -> bool:
	if water_bottles <= 0:
		return false
	water_bottles -= 1
	inventory_changed.emit(fish, water_bottles)
	return true
	
func use_wood(amount: int = 1) -> bool:
	if wood < amount:
		return false
	wood -= amount
	inventory_changed.emit(fish, water_bottles, wood)
	return true
	
func has_any_resources() -> bool:
	return fish > 0 or water_bottles > 0
	
func reset():
	fish = 0
	water_bottles = 0
	inventory_changed.emit(fish, water_bottles)
