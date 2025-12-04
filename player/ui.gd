class_name UI extends CanvasLayer

func set_to_bottom_right():
	$HBoxContainer.set_anchor_and_offset(SIDE_BOTTOM, 1.0, 0)
	$HBoxContainer.set_anchor_and_offset(SIDE_RIGHT, 1.0, 1)
	$HBoxContainer.set_anchor_and_offset(SIDE_TOP, 0.863, 0)
	$HBoxContainer.set_anchor_and_offset(SIDE_LEFT, 0.84, -593)

func update_food_count_label(new_value: int = 0):
	%FoodCount.text = str(new_value)

func update_wood_count_label(new_value: int = 0):
	%WoodCount.text = str(new_value)

func update_stone_count_label(new_value: int = 0):
	%StoneCount.text = str(new_value)

func update_horde_size_label(new_value: int = 0):
	%HordeSize.text = str(new_value)

func update_horde_strength_label(new_value: int = 0):
	%HordeStrength.text = str(new_value)

func update_king_count_label(new_value: int = 0):
	%KingCount.text = str(new_value)
