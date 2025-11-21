extends Node2D

signal activated

func _ready():
	$Fare.disable()
	modulate = Color.TRANSPARENT

func enable():
	$Fare.enable()

func _on_fare_payed(minion: Minion):
	if minion.is_leading:
		minion.convert_to_king()
	else:
		minion.leader.convert_to_king()
	if $Fare.one_time_pay:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
		tween.finished.connect(queue_free)
	activated.emit()
