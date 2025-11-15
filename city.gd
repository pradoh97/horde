class_name City extends Area2D

@export var troops_to_capture: int = 5
@export var max_spawn_speed: float = 1500
@export var min_spawn_speed: float = 700
@export var tween_duration: float = 1
@export var recruit_food_cost: int = 2
var captured = false
var troops_in_city: int = 0

func _ready():
	update_troops_count_label()

func update_troops_count_label():
	%MinionCount.text = str(troops_to_capture - troops_in_city)

func capture_city():
	captured = true
	var tween: Tween = create_tween()
	tween.set_parallel()
	tween.tween_property($Polygon2D, "color", Color("#3f6ecc"), tween_duration)
	tween.tween_property($Polygon2D2, "color", Color("#e1cd28"), tween_duration)

func spawn_troop():
	var new_minion: Minion = Minion.new_minion()
	new_minion.disable_collision()
	new_minion.global_position = global_position
	new_minion.recruit_cost = recruit_food_cost
	get_parent().add_child(new_minion)
	new_minion.velocity = Vector2(randf_range(-max_spawn_speed, max_spawn_speed), randf_range(-max_spawn_speed, max_spawn_speed))

func _on_body_entered(minion: Minion):
	if not captured:
		if minion.army and not minion.is_leading:
			troops_in_city += 1
			if minion.resource_held:
				minion.drop_resource()
			minion.kill()
			update_troops_count_label()
		if troops_to_capture - troops_in_city == 0:
			capture_city()
	else:
		if minion.resource_held:
			minion.drop_resource()


func _on_level_day_passed():
	if captured:
		spawn_troop()
