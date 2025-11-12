class_name CollectibleResource extends Area2D

@export var max_resources: int = 5
@export var use_first_free_minion: bool = false
var resources_available: int = 0

func _ready():
	update_count_label()

func update_count_label():
	$Label.text = str(resources_available)

func get_image() -> Sprite2D:
	return $Sprite2D

func _on_body_entered(minion: Minion):
	if minion.army and resources_available > 0:
		if minion.pick_resource(self):
			resources_available -= 1
			update_count_label()

func _on_level_day_passed():
	if resources_available < max_resources:
		resources_available += 1
		update_count_label()
