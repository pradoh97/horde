extends RigidBody2D

@export var held: bool = false
var strength: float = 50
func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	if held:
		linear_velocity = global_position.direction_to(get_global_mouse_position()) * (global_position.distance_to(get_global_mouse_position()) * strength)
