class_name City extends Building

@export var max_spawn_speed: float = 1500
@export var min_spawn_speed: float = 700
@export var recruit_food_cost: int = 2

func spawn_troop():
	var new_minion: Minion = Minion.new_minion()
	new_minion.disable_collision()
	new_minion.global_position = global_position
	new_minion.recruit_cost = recruit_food_cost
	get_parent().add_child(new_minion)
	new_minion.velocity = Vector2(randf_range(-max_spawn_speed, max_spawn_speed), randf_range(-max_spawn_speed, max_spawn_speed))

func _on_body_entered(minion: Minion):
	if not captured and minion.army and not minion.is_leading and $Fare.is_payment_valid(minion):
		$Fare.charge_payment(minion)

func _on_level_day_passed():
	if captured:
		spawn_troop()
		$WeaponRack._on_level_day_passed()



func _on_king_convert_activated():
	$WeaponRack.enable()


func _on_fare_payed(_minion):
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property($KingConvert, "modulate", Color(1.0, 1.0, 1.0, 1.0), tween_duration)
	$KingConvert.enable()
	capture_building()
	$StockPile.capture_building()
