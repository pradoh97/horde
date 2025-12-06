class_name Army extends Node2D

@export var override_minions_properties: bool = true
@export var max_speed = 2000.0
@export var acceleration: float = 200.0
@export var deceleration_factor: float = 0.15
@export var full_stop_speed: float = 160
@export var max_speed_left_behind: = 2500
@export var player_number := 0
var ui: UI = null :
	set(new_ui):
		ui = new_ui
		update_horde_size()
		update_horde_strength()
		update_food_stock()
		update_wood_stock()
		update_stone_stock()

var horde_size: int = 0
var horde_strength: int = 0
var wood_stock: int = 20
var food_stock: int = 20
var stone_stock: int = 20
var king_count: int = 0

var following_orders: bool = false
var last_mouse_direction: Vector2 = Vector2.ZERO
var chase: bool = true
var leader: Minion = null
var minions: Array[Minion] = []
var free_minions: Array[Minion] = []
var camera: Camera2D = null
var armed_minions: Array[Minion] = []
var commanded_with_arrow_keys := false

# Called when the node enters the scene tree for the first time.
func _ready():
	leader = (get_child(0) as Minion)
	leader.set_physics_process(true)
	minion_dropped_collectible(leader)
	if get_node_or_null("Camera2D"):
		camera = $Camera2D
		camera.army = self

	for minion in get_children():
		if minion is Minion:
			minions.append(minion)

	for minion in minions:
		minion.army = self
		assign_leader()
		if override_minions_properties:
			minion.max_speed = max_speed
			minion.acceleration = acceleration
			minion.deceleration_factor = deceleration_factor
			minion.full_stop_speed = full_stop_speed
			minion.max_speed_left_behind = max_speed_left_behind

func _physics_process(_delta):
	var arrows_direction

	if player_number == 0:
		arrows_direction = Input.get_vector("left", "right", "up", "down")
		if not Input.get_vector("left_p2", "right_p2", "up_p2", "down_p2") == Vector2.ZERO:
			arrows_direction = Input.get_vector("left_p2", "right_p2", "up_p2", "down_p2")
		if not Input.get_vector("left_p1", "right_p1", "up_p1", "down_p1") == Vector2.ZERO:
			arrows_direction = Input.get_vector("left_p1", "right_p1", "up_p1", "down_p1")
	else:
		arrows_direction = Input.get_vector("left_p" + str(player_number),"right_p" + str(player_number),"up_p" + str(player_number),"down_p" + str(player_number))
	if commanded_with_arrow_keys and not arrows_direction:
		disband_minions()

	var player_giving_orders = player_number == 0 and Input.is_action_just_pressed("mouse_click") or arrows_direction
	if player_giving_orders:
		commanded_with_arrow_keys = arrows_direction != Vector2.ZERO
		command_minions()
	if player_number == 0 and Input.is_action_just_released("mouse_click"):
		disband_minions()

func update_food_stock(update_by: int = 0):
	food_stock += update_by
	ui.update_food_count_label(food_stock)

func update_wood_stock(update_by: int = 0):
	wood_stock += update_by
	ui.update_wood_count_label(wood_stock)

func update_stone_stock(update_by: int = 0):
	stone_stock += update_by
	ui.update_stone_count_label(stone_stock)

func update_king_count(update_by: int = 0):
	king_count += update_by
	ui.update_king_count_label(king_count)

func update_horde_size():
	horde_size = minions.size()
	ui.update_horde_size_label(horde_size)

func update_horde_strength():
	horde_strength = armed_minions.size()
	ui.update_horde_strength_label(horde_strength)


func get_ui() -> CanvasLayer:
	return ui

func get_remote_transform() -> RemoteTransform2D:
	return %RemoteTransform2D

func get_food_stock() -> int:
	return food_stock

func get_wood_stock() -> int:
	return wood_stock

func get_stone_stock() -> int:
	return stone_stock

func get_horde_size() -> int:
	return horde_size

func get_horde_strength() -> int:
	return horde_strength

func update_resource_count(resource: CollectibleResource):
	if resource.type == "Wood":
		update_wood_stock(1)
	if resource.type == "Stone":
		update_stone_stock(1)
	if resource.type == "Food":
		update_food_stock(1)
	if resource is Weapon:
		update_horde_strength()

func command_minions():
	chase = true
	for minion in minions:
		minion.be_commanded()

func halt_minions():
	chase = false
	for minion in minions:
		minion.reached_destination = true


func disband_minions():
	chase = false
	for minion in minions:
		minion.be_disbanded()
		minion.set_collision_mask_value(3, true)

func recruit_minion(minion: Minion):
	minion.set_physics_process(true)
	minion.show_health_bar()
	minions.append(minion)
	minion.army = self
	if override_minions_properties:
		minion.acceleration = acceleration
		minion.max_speed = max_speed
		minion.deceleration_factor = deceleration_factor
		minion.full_stop_speed = full_stop_speed
		minion.max_speed_left_behind = max_speed_left_behind
	free_minions.append(minion)
	update_horde_size()
	update_horde_strength()


func kill_minion(minion: Minion):
	if minion.is_leading and minions.size() > 1:
		var old_leader = minions.find(minion)
		leader = minions[old_leader + 1]
		assign_leader()
	if minion.weapon_held:
		armed_minions.erase(minion)
	minions.erase(minion)
	update_horde_size()
	update_horde_strength()
	minion_picked_collectible(minion)

func kill_randomly(amount_to_kill: int):
	for minion_count in range(0, amount_to_kill):
		minions.filter(func(minion): return not minion.is_leading)[0].die()


func minion_picked_collectible(minion: Minion):
	free_minions.erase(minion)

func minion_working(minion: Minion):
	free_minions.erase(minion)

func minion_stopped_working(minion: Minion):
	free_minions.append(minion)

func minion_armed(minion: Minion):
	armed_minions.append(minion)

func minion_dropped_collectible(minion: Minion):
	free_minions.append(minion)

func assign_leader():
	if camera:
		camera.reparent(leader)
		camera.global_position = leader.global_position
	leader.become_leader()

	for minion in minions:
		if not minion.is_leading:
			minion.leader = leader

func get_followers_count() -> int:
	return minions.size()

func get_free_minion() -> Minion:
	var minion: Minion = null
	if free_minions.size():
		minion = free_minions[0]

	return minion

func _on_mouse_area_entered(area):
	var minion: Minion = area.get_parent()
	if minion.is_leading:
		halt_minions()

func _on_mouse_area_exited(area):
	var minion: Minion = area.get_parent()
	if minion.following_orders and minion.is_leading:
		command_minions()
