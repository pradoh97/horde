extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = get_global_mouse_position()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = get_global_mouse_position()
