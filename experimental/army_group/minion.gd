extends CharacterBody2D
class_name MinionAGExperimental

@export var max_speed = 600.0
@export var acceleration: float = 100.0
@export var deceleration_factor: float = 0.025
@export var full_stop_speed: float = 40
var army: ArmyGroup = null
var following_orders: bool = false
var reached_destination: bool = false

func _physics_process(delta):
	if following_orders:
		var army_direction: Vector2 = (army.global_position - global_position).normalized()
		velocity += acceleration * army_direction
	if velocity.x >= max_speed:
		velocity.x = max_speed
	if velocity.x <= -max_speed:
		velocity.x = -max_speed
	if velocity.y <= -max_speed and following_orders:
		velocity.y = -max_speed

	if not following_orders:
		velocity.x = lerp(velocity.x, 0.0, deceleration_factor)
		if velocity.x <= full_stop_speed and velocity.x > 0 or velocity.x >= -full_stop_speed and velocity.x < 0:
			velocity.x = 0
	# Add the gravity.
	if not is_on_floor():
		var gravity_modifier = 1
		if following_orders:
			#if reached_destination:
				#gravity_modifier = 0
			#else:
				gravity_modifier = deceleration_factor
		else:
			gravity_modifier = lerp(gravity_modifier, 1, deceleration_factor)
		velocity.y += get_gravity().y * delta * gravity_modifier
		if following_orders and velocity.y >= max_speed * 1.5:
			velocity.y = max_speed * 1.5
	move_and_slide()
