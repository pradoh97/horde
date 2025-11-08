extends RigidBody2D
@export var pickup = false
@export var in_horde = false
var mouse_in_pickup_area = false
var can_pick_up = false
var picked_up = false

func _physics_process(_delta):
	if mouse_in_pickup_area and Input.is_action_pressed("mouse_click"):
		can_pick_up = true
	if pickup and can_pick_up:
		enable_dragging()
		global_transform.origin = get_global_mouse_position()

	else:
		disable_dragging()

	if Input.is_action_just_released("mouse_click"):
		can_pick_up = false
		disable_dragging()

func enable_dragging(use_sleep: bool = false):
	picked_up = true
	if use_sleep:
		sleeping = true
		gravity_scale = 0
	else:
		freeze = true
		freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC

func disable_dragging(use_sleep: bool = false):
	if use_sleep:
		sleeping = false
		gravity_scale = 1
	else:
		freeze = false
		freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
	picked_up = false

func _on_mouse_entered():
	mouse_in_pickup_area = true

func _on_mouse_exited():
	mouse_in_pickup_area = false
