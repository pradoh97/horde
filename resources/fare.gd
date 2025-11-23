class_name Fare extends Node2D

signal payed(minion: Minion)

@export var one_time_pay: bool = false
@export var enabled: bool = true
@export var allow_partial_payment: bool = false
@export_group("Requirements")
@export var required_food: int = 0
@export var required_wood: int = 0
@export var required_stone: int = 0
@export var required_minions: int = 0
@export_group("Exchange")
@export var exchanged_resource: Texture2D = null
@export var exchange_amount: int = 0

var food_in: int = 0
var wood_in: int = 0
var stone_in: int = 0
var minions_in: int = 0

func _ready():
	%Food/Count.text = str(required_food)
	%Wood/Count.text = str(required_wood)
	%Stone/Count.text = str(required_stone)
	%Minion/Count.text = str(required_minions)
	%ExchangedResource/Count.text = "  " + str(exchange_amount)
	%ExchangedResource/TextureRect.texture = exchanged_resource
	if required_food == 0:
		%Food.visible = false
	if required_wood == 0:
		%Wood.visible = false
	if required_stone == 0:
		%Stone.visible = false
	if required_minions == 0:
		%Minion.visible = false
	if exchange_amount == 0:
		%ExchangedResource.visible = false

func disable():
	enabled = false

func enable():
	enabled = true

func is_payment_valid(minion: Minion) -> bool:
	var level: Level = minion.army.get_level()
	var food_stock = level.get_food_stock()
	var wood_stock = level.get_wood_stock()
	var stone_stock = level.get_stone_stock()
	var horde_size = level.get_horde_size()
	var meets_required_goods = food_stock >= required_food and wood_stock >= required_wood and stone_stock >= required_stone and horde_size > required_minions

	return meets_required_goods

func charge_payment(minion: Minion):
	if enabled:
		var level: Level = minion.army.get_level()
		level.update_food_stock(-required_food)
		level.update_wood_stock(-required_wood)
		level.update_stone_stock(-required_stone)
		payed.emit(minion)
