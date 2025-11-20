class_name Weapon extends CollectibleResource
@export var available_textures: Array[Texture2D]

func pick_random():
	texture = available_textures.pick_random()
