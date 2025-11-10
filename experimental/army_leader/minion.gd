extends CharacterBody2D
class_name MinionExperimental

@export var ignore_gravity: bool = true
@export var max_speed = 600.0
@export var max_speed_left_behind: float = 800.0
@export var acceleration: float = 100.0
@export var deceleration_factor: float = 0.025
@export var full_stop_speed: float = 40
@export var distance_treshold: float = 700.0

var left_behind: bool = false
var is_leading: bool = false
var leader: MinionExperimental = null
var following_orders: bool = false
var reached_destination: bool = false
var army: Army = null
var last_direction: Vector2 = Vector2.ZERO
var direction_counter: int = 0
var executions_until_next_direction_count: int = 40

func _physics_process(delta):
	if following_orders and not reached_destination:
		var leader_direction: Vector2
		if not is_leading:
			leader_direction = (leader.global_position - global_position).normalized()
		else:
			leader_direction = (get_global_mouse_position() - global_position).normalized()

		# Accomodate any left behind minion
		direction_counter += 1
		if direction_counter >= executions_until_next_direction_count:
			direction_counter = 0
			if last_direction != leader_direction and not is_leading and global_position.distance_to(leader.global_position) >= distance_treshold:
				left_behind = true
				velocity = leader.velocity
			else:
				left_behind = false
			last_direction = leader_direction
		velocity += acceleration * leader_direction

	# Caps the velocity if it's already at max. Makes the minion go faster to reach the group if left behind
	if velocity.x >= max_speed:
		if left_behind:
			velocity.x = max_speed_left_behind
		else:
			velocity.x = max_speed
	if velocity.x <= -max_speed:
		if left_behind:
			velocity.x = -max_speed_left_behind
		else:
			velocity.x = -max_speed
	if velocity.y <= -max_speed and (following_orders or ignore_gravity):
		if left_behind:
			velocity.y = -max_speed_left_behind
		else:
			velocity.y = -max_speed
	if ignore_gravity and velocity.y >= max_speed:
		if left_behind:
			velocity.y = max_speed_left_behind
		else:
			velocity.y = max_speed

	# Stops the minion
	if not following_orders or reached_destination:
		velocity.x = lerp(velocity.x, 0.0, deceleration_factor)
		if velocity.x <= full_stop_speed and velocity.x > 0 or velocity.x >= -full_stop_speed and velocity.x < 0:
			velocity.x = 0
		if ignore_gravity:
			velocity.y = lerp(velocity.y, 0.0, deceleration_factor)
			if velocity.y <= full_stop_speed and velocity.y > 0 or velocity.y >= -full_stop_speed and velocity.y < 0:
				velocity.y = 0

	# Add the gravity.
	if not is_on_floor() and not ignore_gravity:
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
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * velocity.x/10)
	move_and_slide()

func be_commanded():
	if not following_orders:
		$AnimationPlayer.play("commanded")
	following_orders = true
	reached_destination = false
	#set_collision_mask_value(3, false)

func be_disbanded():
	if following_orders:
		$AnimationPlayer.play("disbanded")
	following_orders = false
	reached_destination = false
	#set_collision_mask_value(3, false)


func _on_infect_area_body_entered(body):
	if not body == self:
		if not (body as MinionExperimental).leader or not (body as MinionExperimental).is_leading:
			if not leader:
				body.leader = self
			else:
				body.leader = leader
			body.army = army
			army.recruit_minion(body)
