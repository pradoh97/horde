extends CharacterBody2D
class_name ArmyGroup

@export var max_speed = 600.0
@export var acceleration: float = 100.0
@export var deceleration_factor: float = 0.025
@export var full_stop_speed: float = 40
var army: ArmyGroup = null
var following_orders: bool = false
var reached_destination: bool = false
var last_mouse_direction: Vector2 = Vector2.ZERO
var chase: bool = true
var minions: Array[MinionAGExperimental] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_collision_mask_value(3, false)
	for minion in get_children():
		if minion is MinionAGExperimental:
			minions.append(minion)
			minion.army = self
			minion.set_collision_mask_value(2, false)

func _physics_process(delta):
	if Input.is_action_just_pressed("mouse_click"):
		following_orders = true
		chase = true
		command_minions()
	if Input.is_action_pressed("mouse_click") and chase:
		following_orders = true
		var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()
		last_mouse_direction = mouse_direction
		velocity += acceleration * mouse_direction
		command_minions()
	if velocity.x >= max_speed:
		velocity.x = max_speed
	if velocity.x <= -max_speed:
		velocity.x = -max_speed
	if velocity.y <= -max_speed and following_orders:
		velocity.y = -max_speed
	if Input.is_action_just_released("mouse_click"):
		following_orders = false
		chase = false
		halt_minions()
		disband_minions()

	if not following_orders:
		velocity.x = lerp(velocity.x, 0.0, deceleration_factor)
		if velocity.x <= full_stop_speed and velocity.x > 0 or velocity.x >= -full_stop_speed and velocity.x < 0:
			velocity.x = 0
	# Add the gravity.
	if not is_on_floor():
		var gravity_modifier = 1
		if following_orders:
			if reached_destination:
				gravity_modifier = 0
			else:
				gravity_modifier = deceleration_factor
		else:
			gravity_modifier = lerp(gravity_modifier, 1, deceleration_factor)
		velocity.y += get_gravity().y * delta * gravity_modifier
		if following_orders and velocity.y >= max_speed * 1.5:
			velocity.y = max_speed * 1.5

	move_and_slide()

func command_minions():
	for minion in minions:
		minion.reached_destination = false
		minion.following_orders = true

func halt_minions():
	for minion in minions:
		minion.reached_destination = true

func disband_minions():
	for minion in minions:
		minion.following_orders = false

func _on_mouse_body_entered(_body):
	halt_minions()

func _on_mouse_body_exited(_body):
	command_minions()
