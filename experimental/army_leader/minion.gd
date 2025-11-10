extends CharacterBody2D
class_name MinionExperimental

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

func _physics_process(_delta):
	if following_orders and not reached_destination:
		var leader_direction: Vector2
		if not is_leading:
			leader_direction = (leader.global_position - global_position).normalized()
			if global_position.distance_to(leader.global_position) >= distance_treshold:
				left_behind = true
			else:
				left_behind = false
		else:
			leader_direction = (get_global_mouse_position() - global_position).normalized()
		velocity += acceleration * leader_direction

	# Caps the velocity if it's already at max. Makes the minion go faster to reach the group if left behind
	if velocity.length() >= max_speed:
		if left_behind:
			velocity = velocity.normalized() * max_speed_left_behind
		else:
			velocity = velocity.normalized() * max_speed

	# Stops the minion
	if not following_orders or reached_destination:
		velocity = velocity.lerp(Vector2.ZERO, deceleration_factor)
		if velocity.length() <= full_stop_speed:
			velocity = Vector2.ZERO

	#Make it collide against stuff
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
