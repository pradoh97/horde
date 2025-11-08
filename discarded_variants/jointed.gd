extends Node2D

var minions

@onready var master_joint = $MasterJoint
@onready var master_fake_body = $MasterJoint/FakeBody
var is_dragging = false


func _ready() -> void:
	minions = $Minions.get_children()
	for minion in minions:
		var minion_body: RigidBody2D = minion.get_node("RigidBody2D")
		var minion_pin = minion.get_node("MousePin")
		#var minion_fake_body: StaticBody2D = minion_pin.get_node("FakeBody")
		# Enable input pickable on the rigid body to be able to detect mouse clicks
		minion_body.input_pickable = true
		# Connect the input_event signal to its function
		minion_body.input_event.connect(_on_input_event)
		## Set the node_a to a static body without a collision, we only need it for the pin effect.
		#minion_pin.node_a = minion_pin.get_path_to(minion_fake_body)


func _physics_process(_delta: float) -> void:
	master_joint.global_position = get_global_mouse_position()
	for minion in minions:
		var minion_pin = minion.get_node("MousePin")
		minion_pin.global_position = get_global_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	# If we are dragging and the user releases the mouse button then
	if is_dragging and event is InputEventMouseButton and not event.is_pressed():
		is_dragging = false

		for minion in minions:
			var minion_body: RigidBody2D = minion.get_node("RigidBody2D")
			var minion_pin = minion.get_node("MousePin")
			# Clear the node_b path
			minion_pin.node_a = NodePath()
			# Reset the angular damp to 0
			minion_body.angular_damp = 0
			# Or unlock the rotation of the rigid body with
	#		rigid_body_2d.lock_rotation = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# If we aren't dragging and a mouse button press happens then
	if not is_dragging and event is InputEventMouseButton and event.is_pressed():
		is_dragging = true
		for minion in minions:
			var minion_body: RigidBody2D = minion.get_node("RigidBody2D")
			var minion_pin = minion.get_node("MousePin")
			# Set the node_b to the rigid body that triggered this input event
			minion_pin.node_a = minion_pin.get_path_to(minion_body)
			# Up the angular damp to avoid rotating like crazy when moving the mouse
			minion_body.angular_damp = 10
			# You can also lock the rotation of the rigid body with
			#rigid_body_2d.lock_rotation = true
