extends Camera2D

@export var tween_duration: float = 0.5
@export var initial_zoom_percentage := 0.8
var max_zoom = Vector2(0.9, 0.9)
var min_zoom = Vector2(0.1, 0.1)
var zoom_tween: Tween
var zoom_step_factor: Vector2 = Vector2(0.1, 0.1)
var zoom_step = 0
var max_steps = 0
var min_steps = 1

func _ready():
	zoom_step = ceili((max_zoom.x-min_zoom.x)/zoom_step_factor.x/2)
	max_steps = ceili((max_zoom.x-min_zoom.x)/zoom_step_factor.x)
	zoom = max_zoom*initial_zoom_percentage

func _input(event):
	if event.is_action_pressed("mouse_scroll_down"):
		zoom_step = clamp(zoom_step - 1, min_steps, max_steps)
		if zoom_step > min_steps:
			zoom_tween = create_tween()
			zoom_tween.tween_property(self, "zoom", zoom_step_factor * zoom_step, tween_duration)

	if event.is_action_pressed("mouse_scroll_up"):
		zoom_step = clamp(zoom_step + 1, min_steps, max_steps)
		if zoom_step <= max_steps:
			zoom_tween = create_tween()
			zoom_tween.tween_property(self, "zoom", zoom_step_factor * zoom_step, tween_duration)
