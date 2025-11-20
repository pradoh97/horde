class_name Level extends Node2D
signal day_passed

@export var day_duration: int = 3
var wood_stock: int = 0
var food_stock: int = 0
var stone_stock: int = 0
var king_count: int = 0

func _ready():
	$Mouse.area_entered.connect($Army._on_mouse_area_entered)
	$Mouse.area_exited.connect($Army._on_mouse_area_exited)
	$DayTicker.wait_time = day_duration
	$DayTicker.start()
	$Army.level = self
	update_horde_size()
	update_horde_strength()


func update_food_stock(update_by: int = 0):
	food_stock += update_by
	$UI.update_food_count_label(food_stock)

func update_wood_stock(update_by: int = 0):
	wood_stock += update_by
	$UI.update_wood_count_label(wood_stock)

func update_stone_stock(update_by: int = 0):
	stone_stock += update_by
	$UI.update_stone_count_label(stone_stock)

func update_king_count(update_by: int = 0):
	king_count += update_by
	$UI.update_king_count_label(king_count)

func update_horde_size():
	$UI.update_horde_size_label($Army.minions.size())

func update_horde_strength():
	$UI.update_horde_strength_label($Army.armed_minions.size())

func get_food_stock() -> int:
	return food_stock

func get_wood_stock() -> int:
	return wood_stock

func get_stone_stock() -> int:
	return stone_stock

func update_resource_count(resource: CollectibleResource):
	if resource.type == "Wood":
		update_wood_stock(1)
	if resource.type == "Stone":
		update_stone_stock(1)
	if resource.type == "Food":
		update_food_stock(1)
	if resource is Weapon:
		update_horde_strength()

func _on_day_ticker_timeout():
	day_passed.emit()
