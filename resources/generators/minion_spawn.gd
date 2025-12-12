class_name MinionSpawn extends CollectibleResourceGenerator

@export var recruit_food_cost := 2

func _ready():
	$Fare.required_food = recruit_food_cost
	collectibles_available += 1
	if not enabled:
		modulate = Color.TRANSPARENT
		disable()

func spawn_minion():
	var new_minion: Minion = Minion.new_minion()
	new_minion.disable_collision()
	new_minion.be_disbanded()
	add_child(new_minion)
	var random_spawn_distance = Vector2(randf_range(-100,100), randf_range(-100,100))
	new_minion.global_position = global_position + random_spawn_distance

func enable():
	super()
	$CollisionShape2D.set_deferred("disabled", false)

func disable():
	super()
	$CollisionShape2D.set_deferred("disabled", true)

func _on_body_entered(minion: Minion):
	if minion.army and not minion.weapon_held and $Fare.is_payment_valid(minion) and enabled:
		$Fare.charge_payment(minion)


func _on_fare_paid(minion: Minion):
	call_deferred("spawn_minion")


func _on_area_entered(area):
	if area.get_parent() and area.get_parent() is Minion:
		_on_body_entered(area.get_parent())
