class_name WeaponRack extends CollectibleResourceGenerator

func _ready():
	collectibles_available += 1
	if not enabled:
		modulate = Color.TRANSPARENT

func _on_level_day_passed():
	pass

func _on_body_entered(minion: Minion):
	if minion.army and $Fare.payment_valid(minion) and enabled:
		if minion.pick_up_collectible(collectible_generated):
			$Fare.charge_payment(minion)
