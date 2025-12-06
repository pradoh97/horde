@tool
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
	%ExchangedResource/Count.text = "  " + str(exchange_amount)
	%ExchangedResource/TextureRect.texture = exchanged_resource

	update_resources_count()
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

func update_resources_count():
	%Food/Count.text = str(required_food - food_in)
	%Wood/Count.text = str(required_wood - wood_in)
	%Stone/Count.text = str(required_stone - stone_in)
	%Minion/Count.text = str(required_minions - minions_in)

func disable():
	enabled = false

func enable():
	enabled = true

func is_payment_valid(minion: Minion = null) -> bool:
	var food_stock
	var wood_stock
	var stone_stock
	var horde_size
	if minion:
		food_stock = minion.army.get_food_stock()
		wood_stock = minion.army.get_wood_stock()
		stone_stock = minion.army.get_stone_stock()
		horde_size = minion.army.get_horde_size()
	else:
		food_stock = food_in
		wood_stock = wood_in
		stone_stock = stone_in
		horde_size = minions_in
	var meets_required_goods = food_stock >= required_food and wood_stock >= required_wood and stone_stock >= required_stone and ((minion and horde_size > required_minions) or horde_size == required_minions)

	return meets_required_goods

func charge_payment(minion: Minion):
	if not enabled:
		return
	var payed_food_amount := 0
	var payed_wood_amount := 0
	var payed_stone_amount := 0
	var payed_minions_amount := 0

	if allow_partial_payment:
		if minion.resource_held:
			if minion.resource_held.type == "Food" and food_in < required_food:
				payed_food_amount = 1
			if minion.resource_held.type == "Wood" and wood_in < required_wood:
				payed_wood_amount = 1
			if minion.resource_held.type == "Stone" and stone_in < required_stone:
				payed_stone_amount = 1
		if required_minions - minions_in > 0 and not minion.is_leading:
			payed_minions_amount = 1
	else:
		payed_food_amount = required_food
		payed_wood_amount = required_wood
		payed_stone_amount = required_stone
		payed_minions_amount = required_minions

	minions_in += payed_minions_amount
	food_in += payed_food_amount
	wood_in += payed_wood_amount
	stone_in += payed_stone_amount

	minion.army.update_food_stock(-payed_food_amount)
	minion.army.update_wood_stock(-payed_wood_amount)
	minion.army.update_stone_stock(-payed_stone_amount)

	if payed_minions_amount:
		if allow_partial_payment and not minion.is_leading:
			minion.die()
		else:
			minion.army.kill_randomly(payed_minions_amount)
	if one_time_pay:
		update_resources_count()

	if is_payment_valid():
		payed.emit(minion)
