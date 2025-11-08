extends Node2D
class_name Army

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
		if not minion == leader:
			minion.leader = leader

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
		minion.reached_destination = false
		minion.following_orders = true

func halt_minions():
	chase = false
	for minion in minions:
		minion.reached_destination = true

func disband_minions():
	chase = false
	for minion in minions:
		minion.following_orders = false

func _on_mouse_body_entered(body):
	halt_minions()

func _on_mouse_body_exited(body):
	if leader.following_orders and body == leader:
		command_minions()
