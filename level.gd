class_name Level extends Node2D
signal day_passed

@export var day_duration: int = 3

func _ready():
	$Mouse.area_entered.connect($Army._on_mouse_area_entered)
	$Mouse.area_exited.connect($Army._on_mouse_area_exited)
	$DayTicker.wait_time = day_duration
	$DayTicker.start()
	$Army.level = self

func _on_day_ticker_timeout():
	day_passed.emit()
