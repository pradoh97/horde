extends Area2D

@export var max_resources: int = 5
var captured = false
var resources_available: int = 0

func _ready():
	update_troops_count_label()

func update_troops_count_label():
	$Label.text = str(resources_available)

func capture_city():
	captured = true

func _on_body_entered(minion: Minion):
	if minion.army and resources_available > 0:
		resources_available -= 1
		minion.pick_resource(self)


func _on_level_day_passed():
	if resources_available < max_resources:
		resources_available += 1
