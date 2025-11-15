class_name UI extends CanvasLayer

func update_food_count_label(new_value: int = 0):
	%FoodCount.text = str(new_value)

func update_wood_count_label(new_value: int = 0):
	%WoodCount.text = str(new_value)

func update_stone_count_label(new_value: int = 0):
	%StoneCount.text = str(new_value)

func update_horde_size_label(new_value: int = 0):
	%HordeSize.text = str(new_value)
