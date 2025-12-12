class_name City extends Building

@export var max_spawn_speed: float = 1500
@export var min_spawn_speed: float = 700
@export var recruit_food_cost: int = 2


func _on_body_entered(minion: Minion):
	if not captured and minion.army and ($CaptureFare.is_payment_valid(minion) or $CaptureFare.allow_partial_payment):
		$CaptureFare.charge_payment(minion)

func _on_level_day_passed():
	if captured:
		$WeaponRack._on_level_day_passed()

func _on_king_convert_activated():
	$WeaponRack.enable()

func _on_capture_fare_paid(minion):
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property($KingConvert, "modulate", Color(1.0, 1.0, 1.0, 1.0), tween_duration)
	tween.tween_property($MinionSpawn, "modulate", Color(1.0, 1.0, 1.0, 1.0), tween_duration)
	tween.tween_property($CaptureFare, "modulate", Color.TRANSPARENT, tween_duration)

	tween.finished.connect($CaptureFare.queue_free)
	$KingConvert.enable()
	$MinionSpawn.enable()
	$MinionSpawn.recruit_food_cost = recruit_food_cost
	capture_building(minion.army)
	$StockPile.capture_building(minion.army)


func _on_area_entered(area):
	if area.get_parent() and area.get_parent() is Minion:
		_on_body_entered(area.get_parent())
