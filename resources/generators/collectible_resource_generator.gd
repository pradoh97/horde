class_name CollectibleResourceGenerator extends Area2D

@export var max_collectibles: int = 5
@export var generation_factor: float = 1.0
@export var use_first_free_minion: bool = false
@export var collectible_generated: CollectibleResource = null
@export var enabled: bool = true

var collectibles_available: int = 0

func _ready():
	if not enabled:
		modulate = Color.TRANSPARENT
	update_count_label()

func enable():
	enabled = true
	modulate = Color(1.0, 1.0, 1.0, 1.0)

func update_count_label():
	$Label.text = str(collectibles_available)

func _on_body_entered(minion: Minion):
	if minion.army and collectibles_available > 0:
		if minion.pick_up_collectible(collectible_generated):
			collectibles_available -= 1
			update_count_label()

func _on_level_day_passed():
	if collectibles_available < max_collectibles and enabled:
		collectibles_available += floor(1*generation_factor)
		update_count_label()
