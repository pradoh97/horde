extends Node2D

func _ready():
	$Mouse.area_entered.connect($Army._on_mouse_area_entered)
	$Mouse.area_exited.connect($Army._on_mouse_area_exited)
