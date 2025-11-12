extends CharacterBody2D
class_name Minion

@export var max_speed = 600.0
@export var max_speed_left_behind: float = 800.0
@export var acceleration: float = 100.0
@export var deceleration_factor: float = 0.025
@export var full_stop_speed: float = 40
@export var distance_treshold: float = 700.0
const minion_scene: PackedScene = preload("res://minion/minion.tscn")

var left_behind: bool = false
var is_leading: bool = false
var leader: Minion = null
var following_orders: bool = false
var reached_destination: bool = false
var army: Army = null
var last_direction: Vector2 = Vector2.ZERO
var direction_counter: int = 0
var queued_for_death: bool = false
var resource_held: CollectibleResource = null

static func new_minion() -> Minion:
	return minion_scene.instantiate()


func _physics_process(_delta):
	if following_orders and not reached_destination or left_behind:
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
	if (not following_orders or reached_destination) and not left_behind:
		velocity = velocity.lerp(Vector2.ZERO, deceleration_factor)
		if velocity.length() <= full_stop_speed:
			velocity = Vector2.ZERO

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

func get_army_followers_count() -> int:
	return army.get_followers_count()

func kill():
	army.kill_minion(self)
	queue_free()

func pick_resource(resource: CollectibleResource) -> bool:
	var picked_successfully: bool = false

	if not resource_held:
		resource_held = resource
		var image = resource.get_image()
		$Resource.texture = image.texture
		$Resource.scale = image.scale
		picked_successfully = true
		army.minion_picked_collectible(self)
	else:
		var free_minion = get_free_minion()
		if free_minion:
			picked_successfully = free_minion.pick_resource(resource)
	return picked_successfully

func drop_resource() -> CollectibleResource:
	var resource_dropped = resource_held
	resource_held = null
	%Resource.texture = null
	%Resource.scale = Vector2(1,1)
	return resource_dropped

func get_free_minion() -> Minion:
	return army.get_free_minion()

func _on_infect_area_body_entered(minion: Minion):
	#Minion in the army hits an unregistered minion. To join the hitting minion has to be in an army and the other one does not
	if not minion == self and not minion.army and self.army:
		if not leader:
			minion.leader = self
		else:
			minion.leader = leader
		army.recruit_minion(minion)
