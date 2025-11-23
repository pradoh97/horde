class_name Building extends Area2D

@export var tween_duration: float = 1
@export var inner_color_converted: Color
@export var outer_color_converted: Color
var captured = false

func capture_building():
	captured = true
	var tween: Tween = create_tween()
	tween.set_parallel()
	tween.tween_property(%Polygon2D, "color", inner_color_converted, tween_duration)
	tween.tween_property(%Polygon2D2, "color", outer_color_converted, tween_duration)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), tween_duration)
