class_name Fare extends Area2D

signal payed(minion: Minion)

@export var required_food: int = 0
@export var required_wood: int = 0
@export var required_stone: int = 0
@export var required_minions: int = 0
@export var one_time_pay: bool = false
@export var use_parent_collision: bool = false

func _ready():
	%Food/Count.text = str(required_food)
	%Wood/Count.text = str(required_wood)
	%Stone/Count.text = str(required_stone)
	%Minion/Count.text = str(required_minions)
	if required_food == 0:
		%Food.visible = false
	if required_wood == 0:
		%Wood.visible = false
	if required_stone == 0:
		%Stone.visible = false
	if required_minions == 0:
		%Minion.visible = false
	if use_parent_collision:
		disable()

func disable():
	$CollisionShape2D.set_deferred("disabled", true)

func enable():
	$CollisionShape2D.set_deferred("disabled", false)

func payment_valid(minion: Minion) -> bool:
	var level: Level = minion.army.get_level()
	var food_stock = level.get_food_stock()
	var wood_stock = level.get_wood_stock()
	var stone_stock = level.get_stone_stock()
	var horde_size = level.get_horde_size()
	var meets_required_goods = food_stock >= required_food and wood_stock >= required_wood and stone_stock >= required_stone and horde_size > required_minions

	return meets_required_goods

func charge_payment(minion: Minion):
	var level: Level = minion.army.get_level()
	level.update_food_stock(-required_food)
	level.update_wood_stock(-required_wood)
	level.update_stone_stock(-required_stone)
	payed.emit(minion)
	if one_time_pay:
		$CollisionShape2D.set_deferred("disabled", true)


func _on_body_entered(minion: Minion):
	if minion.is_leading and payment_valid(minion):
		charge_payment(minion)
