class_name Building extends Area2D

@export var troops_to_capture: int = 5
@export var wood_to_capture: int = 5
@export var stone_to_capture: int = 5
@export var food_to_capture: int = 5
@export var tween_duration: float = 1
@export var inner_color_converted: Color
@export var outer_color_converted: Color
var captured = false
var troops_in: int = 0
var wood_in: int = 0
var stone_in: int = 0
var food_in: int = 0

func capture_building():
	captured = true
	var tween: Tween = create_tween()
	tween.set_parallel()
	tween.tween_property(%Polygon2D, "color", inner_color_converted, tween_duration)
	tween.tween_property(%Polygon2D2, "color", outer_color_converted, tween_duration)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), tween_duration)

func _on_body_entered(_minion: Minion):
	pass
