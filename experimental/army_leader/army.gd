extends Node2D
class_name Army

@export var override_minions_properties: bool = false
@export var max_speed = 600.0
@export var acceleration: float = 100.0
@export var deceleration_factor: float = 0.025
@export var full_stop_speed: float = 40

var following_orders: bool = false
var last_mouse_direction: Vector2 = Vector2.ZERO
var chase: bool = true
var leader: MinionExperimental = null
var minions: Array[MinionExperimental] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	leader = (get_child(0) as MinionExperimental)
	leader.is_leading = true

	for minion in get_children():
		minions.append(minion)

	for minion in minions:
		minion.army = self
		if not minion == leader:
			minion.leader = leader
		if override_minions_properties:
			minion.max_speed = max_speed
			minion.acceleration = acceleration
			minion.deceleration_factor = deceleration_factor
			minion.full_stop_speed = full_stop_speed

func _physics_process(delta):
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

func recruit_minion(new_minion: MinionExperimental):
	minions.append(new_minion)
	if override_minions_properties:
		new_minion.acceleration = acceleration
		new_minion.max_speed = max_speed
		new_minion.deceleration_factor = deceleration_factor
		new_minion.full_stop_speed = full_stop_speed

func _on_mouse_body_entered(body):
	halt_minions()

func _on_mouse_body_exited(body):
	if leader.following_orders and body == leader:
		command_minions()
