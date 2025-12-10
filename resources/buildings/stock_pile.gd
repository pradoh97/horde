class_name Stockpile extends Building

@export var stock: Array[CollectibleResource]
var ui: UI
var thieves: Array[Dictionary] = []

func _ready():
	$CollisionShape2D.set_deferred("disabled", true)
	modulate = Color.TRANSPARENT
	%Polygon2D.color = inner_color_converted
	%Polygon2D2.color = outer_color_converted

func _on_body_entered(minion: Minion):
	var minion_in_controller_army = minion.army and minion.army == controlled_by
	if minion.resource_held and minion_in_controller_army:
		update_resources(minion.resource_held.type, 1)
		minion.drop_resource()

	var minion_in_enemy_army = minion.army and not minion.army == controlled_by
	var available_types = stock.filter(func(resource: CollectibleResource): return resource.quantity > 0)
	var minion_able_to_collect = not minion.resource_held and not minion.working
	if minion_in_enemy_army and available_types and minion_able_to_collect:
		var resource: CollectibleResource = available_types.pick_random()
		minion.work()
		resource.quantity -= 1
		thieves.append({"minion": minion, "resource": resource})
		if not minion.work_done.is_connected(_on_resource_stolen):
			minion.work_done.connect(_on_resource_stolen.bind(minion))

func capture_building(army: Army = null):
	$CollisionShape2D.set_deferred("disabled", false)
	army.stockpile = self
	ui = army.get_ui()
	super(army)
	refresh_ui()

func refresh_ui():
	for item in stock:
		match item.type:
			CollectibleResource.TYPE.FOOD:
				ui.update_food_count_label(item.quantity)
			CollectibleResource.TYPE.WOOD:
				ui.update_wood_count_label(item.quantity)
			CollectibleResource.TYPE.STONE:
				ui.update_stone_count_label(item.quantity)

func update_resources(type: CollectibleResource.TYPE, amount = 1):
	stock.filter(func(item): return item.type == type)[0].quantity += amount

	refresh_ui()
func _on_area_entered(area):
	if area.get_parent() and area.get_parent() is Minion:
		_on_body_entered(area.get_parent())

func get_wood_stock():
	return stock.filter(func(item): return item.type == CollectibleResource.TYPE.WOOD)[0].quantity

func get_food_stock():
	return stock.filter(func(item): return item.type == CollectibleResource.TYPE.FOOD)[0].quantity

func get_stone_stock():
	return stock.filter(func(item): return item.type == CollectibleResource.TYPE.STONE)[0].quantity

func _on_area_exited(area):
	if area.get_parent() and area.get_parent() is Minion:
		_on_body_exited(area.get_parent())

func _on_body_exited(minion: Minion):
	var thieve = thieves.filter(func(item): return item.minion == minion)
	if thieve.size():
		thieve = thieve[0]

		var thieve_index = thieves.find(thieve)
		if thieve_index >= 0:
			thieves[thieve_index].resource.quantity += 1
			refresh_ui()
			thieves.erase(thieve)
			minion.stop_work()
	if minion.work_done.is_connected(_on_resource_stolen):
		minion.work_done.disconnect(_on_resource_stolen)

func _on_resource_stolen(minion: Minion):
	var thieve = thieves.filter(func(item): return item.minion == minion)

	if thieve.size():
		thieve = thieve[0]
		var thieve_index = thieves.find(thieve)
		if thieve_index >= 0:
			minion.pick_up_collectible(thieves[thieve_index].resource)
			refresh_ui()
			thieves.erase(thieve)

	if minion.work_done.is_connected(_on_resource_stolen):
		minion.work_done.disconnect(_on_resource_stolen)
