extends Area2D

signal activated

func _ready():
	modulate = Color.TRANSPARENT

func enable():
	$Fare.enable()

func _on_fare_paid(minion: Minion):
	$Fare.disable()
	if minion.is_leading:
		minion.convert_to_king()
	else:
		minion.leader.convert_to_king()
	if $Fare.one_time_pay:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
		tween.finished.connect(queue_free)
	activated.emit()


func _on_body_entered(minion: Minion):
	if minion.is_leading and ($Fare as Fare).is_payment_valid(minion):
		$Fare.charge_payment(minion)


func _on_area_entered(area):
	if area.get_parent() and area.get_parent() is Minion:
		_on_body_entered(area.get_parent())
