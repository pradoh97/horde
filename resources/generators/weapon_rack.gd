class_name WeaponRack extends CollectibleResourceGenerator

func _ready():
	collectibles_available += 1
	if not enabled:
		modulate = Color.TRANSPARENT
		disable()

func enable():
	super()
	$CollisionShape2D.set_deferred("disabled", false)

func disable():
	super()
	$CollisionShape2D.set_deferred("disabled", true)

func _on_body_entered(minion: Minion):
	if minion.army and not minion.weapon_held and $Fare.is_payment_valid(minion) and enabled:
		$Fare.charge_payment(minion)


func _on_fare_payed(minion: Minion):
	minion.pick_up_collectible(collectible_generated)
