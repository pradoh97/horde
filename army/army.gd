class_name Army extends Node2D

@export var override_minions_properties: bool = false
@export var max_speed = 600.0
@export var acceleration: float = 100.0
@export var deceleration_factor: float = 0.025
@export var full_stop_speed: float = 40
@export var max_speed_left_behind: = 1000

var following_orders: bool = false
var last_mouse_direction: Vector2 = Vector2.ZERO
var chase: bool = true
var leader: Minion = null
var minions: Array[Minion] = []
var free_minions: Array[Minion] = []
var camera: Camera2D = null
var level: Level = null
var armed_minions: Array[Minion] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	leader = (get_child(0) as Minion)
	leader.set_physics_process(true)
	minion_dropped_collectible(leader)
	camera = $Camera2D
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
	if Input.is_action_just_pressed("mouse_click"):
		command_minions()
	if Input.is_action_pressed("mouse_click") and chase:
		command_minions()
	if Input.is_action_just_released("mouse_click"):
		disband_minions()

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
	minions.append(minion)
	minion.army = self
	if override_minions_properties:
		minion.acceleration = acceleration
		minion.max_speed = max_speed
		minion.deceleration_factor = deceleration_factor
		minion.full_stop_speed = full_stop_speed
		minion.max_speed_left_behind = max_speed_left_behind
	free_minions.append(minion)
	get_level().update_horde_size()
	get_level().update_horde_strength()


func kill_minion(minion: Minion):
	if minion.is_leading and minions.size() > 1:
		var old_leader = minions.find(minion)
		leader = minions[old_leader + 1]
		assign_leader()
	minions.erase(minion)
	get_level().update_horde_size()
	get_level().update_horde_strength()
	minion_picked_collectible(minion)

func kill_randomly(amount_to_kill: int):
	for minion_count in range(0, amount_to_kill):
		minions.filter(func(minion): return not minion.is_leading)[0].kill()


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

func get_level() -> Level:
	return level

func _on_mouse_area_entered(area):
	var minion: Minion = area.get_parent()
	if minion.is_leading:
		halt_minions()

func _on_mouse_area_exited(area):
	var minion: Minion = area.get_parent()
	if minion.following_orders and minion.is_leading:
		command_minions()
