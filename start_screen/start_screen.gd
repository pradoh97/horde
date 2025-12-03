extends Control

@export var single_player_scene: PackedScene
@export var pvp_scene: PackedScene

func _on_single_player_pressed() -> void:
	get_tree().change_scene_to_packed(single_player_scene)

func _on_player_vs_player_pressed() -> void:
	get_tree().change_scene_to_packed(pvp_scene)
