class_name CollectibleResourceGenerator extends Area2D

@export var max_collectibles: int = 5
@export var generation_factor: float = 1.0
@export var use_first_free_minion: bool = false
@export var collectibles_always_available: bool = false
@export var work_required: bool = true
@export var collectible_generated: CollectibleResource = null
@export var enabled: bool = true

var collectibles_available: int = 0

func _ready():
	if not enabled:
		modulate = Color.TRANSPARENT
	else:
		update_count_label()

func enable():
	enabled = true

func disable():
	enabled = false

func update_count_label():
	$Label.text = str(collectibles_available)

func _on_body_entered(minion: Minion):
	if minion.army and (collectibles_available > 0 or collectibles_always_available) and enabled and not minion.resource_held:
		if not work_required:
			collectibles_available -= 1
			pick_up_collectible(minion)
		elif not minion.working:
			minion.work()
			collectibles_available -= 1
			if not minion.work_done.is_connected(pick_up_collectible):
				minion.work_done.connect(pick_up_collectible.bind(minion))

func pick_up_collectible(minion: Minion):
	minion.pick_up_collectible(collectible_generated)
	update_count_label()
	minion.work_done.disconnect(pick_up_collectible)

func _on_level_day_passed():
	if collectibles_available < max_collectibles and enabled:
		collectibles_available += floor(1*generation_factor)
		update_count_label()

func _on_area_entered(area):
	if area.get_parent() and area.get_parent() is Minion:
		_on_body_entered(area.get_parent())
