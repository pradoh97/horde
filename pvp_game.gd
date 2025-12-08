extends Node

func _ready():
	$VBoxContainer/SubViewportContainer2/SubViewport.world_2d = $VBoxContainer/SubViewportContainer/SubViewport.world_2d

func _on_level_army_ready(army: Army, remote_transform: RemoteTransform2D):
	if army.player_number == 1:
		remote_transform.remote_path = %Player1Camera.get_path()
		army.ui = %Player1UI
		%Player1Camera.army = army
		army.camera = %Player1Camera
	if army.player_number == 2:
		remote_transform.remote_path = %Player2Camera.get_path()
		army.ui = %Player2UI
		%Player2Camera.army = army
		army.camera = %Player2Camera
		army.get_ui().set_to_bottom_right()
