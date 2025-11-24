extends CharacterBody2D
class_name Minion

signal work_done
signal attacked(damage)

@export var max_speed = 600.0
@export var max_speed_left_behind: float = 800.0
@export var acceleration: float = 100.0
@export var deceleration_factor: float = 0.025
@export var full_stop_speed: float = 40
@export var distance_treshold: float = 700.0
@export var work_distance_treshold_factor: float = 3.0
@export var attack := 5
@export var health := 10
const minion_scene: PackedScene = preload("res://minion/minion.tscn")

var recruit_cost: int = 0
var left_behind: bool = false
var interrupt_work: bool = false
var is_leading: bool = false
var leader: Minion = null
var can_move := false
var is_busy := false
var following_orders: bool = false
var reached_destination: bool = false
var army: Army = null
var last_direction: Vector2 = Vector2.ZERO
var direction_counter: int = 0
var queued_for_death: bool = false
var resource_held: CollectibleResource = null
var weapon_held: Weapon = null
var working: bool = false
var work_zone_position: Vector2 = Vector2.ZERO
var target_enemy: Enemy = null
var targeted_by := []
var battling := false

func _ready():
	set_physics_process(false)

static func new_minion() -> Minion:
	return minion_scene.instantiate()

func _physics_process(_delta):
	left_behind = not is_leading and global_position.distance_to(leader.global_position) >= distance_treshold
	interrupt_work = (not is_leading and global_position.distance_to(leader.global_position) >= distance_treshold * work_distance_treshold_factor) or (is_leading and working and global_position.distance_to(work_zone_position) >= distance_treshold * work_distance_treshold_factor)

	is_busy = (working or battling) and not is_leading
	can_move = not is_busy and (left_behind or following_orders and not reached_destination)

	if interrupt_work:
		stop_work()
		disengage_fight()

	# Set the direction and velocity
	if can_move:
		var leader_direction: Vector2
		if not is_leading:
			leader_direction = (leader.global_position - global_position).normalized()
		else:
			leader_direction = (get_global_mouse_position() - global_position).normalized()
		velocity += acceleration * leader_direction
	else:
		velocity = velocity.lerp(Vector2.ZERO, deceleration_factor)
		if velocity.length() <= full_stop_speed:
			velocity = Vector2.ZERO

	# Caps the velocity if it's already at max. Makes the minion go faster to reach the group if left behind
	if velocity.length() >= max_speed:
		if left_behind:
			velocity = velocity.normalized() * max_speed_left_behind
		else:
			velocity = velocity.normalized() * max_speed

	move_and_slide()
	set_debug()

func set_debug():
	%State/Properties1/Battling.text = "Battling: " + str(battling)
	%State/Properties1/Working.text = "Working: " + str(working)
	%State/Properties1/HoldingItem.text = "Holding item: " + str(resource_held != null)
	%State/Properties1/Armed.text = "Weapon held: " + str(weapon_held != null)
	%State/Properties2/CanMove.text = "Can move: " + str(can_move)
	%State/Properties2/IsBusy.text = "Is busy: " + str(is_busy)
	%State/Properties2/LeftBehind.text = "Left behind: " + str(left_behind)
	%State/Properties2/FollowingOrders.text = "Following orders: " + str(following_orders)
	%State/Properties3/Health.text = "Health: " + str(health)
	$State/Properties3/TargetEnemy.text = "Target enemy: " + str(target_enemy)
	$State/Properties3/TargetedBy.text = "Targeted by: " + str(targeted_by)


func be_commanded():
	if not following_orders:
		$AnimationPlayer.play("commanded")
	following_orders = true
	reached_destination = false

func be_disbanded():
	if following_orders:
		$AnimationPlayer.play("disbanded")
	following_orders = false
	reached_destination = false

func become_leader():
	$Sprite2D.self_modulate = Color("#f68a9e")
	is_leading = true

func work():
	working = true
	army.minion_working(self)
	work_zone_position = global_position
	if not is_leading:
		$CollisionShape2D.set_deferred("disabled", true)
	$ActivityAnimations.play("working")

func stop_work():
	$ActivityAnimations.stop()
	$ActivityProgress.value = 0
	$ActivityProgress.visible = false
	working = false
	army.minion_stopped_working(self)
	if not is_leading:
		$CollisionShape2D.set_deferred("disabled", false)

func get_army_followers_count() -> int:
	return army.get_followers_count()

func kill():
	army.kill_minion(self)
	queue_free()

func pick_up_collectible(collectible: CollectibleResource):
	if collectible is Weapon:
		if not weapon_held:
			weapon_held = collectible as Weapon
			weapon_held.pick_random()
			%Weapon.texture = weapon_held.texture
			army.minion_armed(self)
			army.get_level().update_resource_count(collectible)
	elif not resource_held:
		resource_held = collectible
		%Resource.texture = collectible.texture
		army.minion_picked_collectible(self)

func drop_resource():
	army.get_level().update_resource_count(resource_held)
	army.minion_dropped_collectible(self)
	resource_held = null
	%Resource.texture = null

func get_free_minion() -> Minion:
	return army.get_free_minion()

func disable_collision():
	$CollisionShape2D.set_deferred("disabled", true)

func enable_collision():
	$CollisionShape2D.set_deferred("disabled", false)

func convert_to_king():
	army.get_level().update_king_count(+1)
	%Crown.visible = true

func engage_fight(enemy: Enemy):
	battling = true

	if not target_enemy:
		target_enemy = enemy
		if not target_enemy.died.is_connected(_on_enemy_died):
			target_enemy.died.connect(_on_enemy_died)
		if not target_enemy.requested_new_enemy.is_connected(_on_enemy_requested_new_enemy):
			target_enemy.requested_new_enemy.connect(_on_enemy_requested_new_enemy)
		if not attacked.is_connected(target_enemy.receive_damage):
			attacked.connect(target_enemy.receive_damage)
		work()

func disengage_fight():
	battling = false
	target_enemy = null
	stop_work()

func receive_damage(damage):
	health -= damage
	if health <= 0:
		kill()

func _on_enemy_died(enemy: Enemy):
	targeted_by.erase(enemy)
	target_enemy = null
	disengage_fight()

func _on_enemy_requested_new_enemy(enemy: Enemy):
	enemy.engage_fight(self)

func _on_infect_area_area_entered(area):
	#Minion in the army hits an unregistered minion. To join the hitting minion has to be in an army and the minion being hit does not.
	var minion: Minion = area.get_parent()
	if not minion == self and not minion.army and army:
		var purchase_able = army.get_level().get_food_stock() >= minion.recruit_cost and minion.recruit_cost > 0
		if purchase_able or minion.recruit_cost == 0:
			if purchase_able:
				army.get_level().update_food_stock(-2)
			if not leader:
				minion.leader = self
			else:
				minion.leader = leader
			minion.enable_collision()
			army.recruit_minion(minion)

func _on_activity_animations_animation_finished(_anim_name):
	if not battling:
		stop_work()
		work_done.emit()
	else:
		var damage: int = randi_range(ceil(attack*0.4), attack)
		if weapon_held:
			damage *= randf_range(ceil(attack*1.2), 1.5)
		%State/Properties3/LastAttack.text = "Last damage dealt: " + str(damage)
		attacked.emit(damage)
		if target_enemy:
			$ActivityAnimations.play("working")
