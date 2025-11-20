extends Area2D

@export var required_food: int = 5
@export var required_wood: int = 10
@export var required_stone: int = 10
@export var required_minions: int = 1
signal activated

func _ready():
	$CollisionShape2D.set_deferred("disabled", true)
	modulate = Color.TRANSPARENT
	%MinionCount.text = str(required_minions)
	%FoodCount.text = str(required_food)
	%WoodCount.text = str(required_wood)
	%StoneCount.text = str(required_stone)

func enable():
	$CollisionShape2D.set_deferred("disabled", false)

func _on_body_entered(body):
	if body is Minion:
		body = body as Minion
		if body.is_leading:
			var food_stock = body.army.get_level().get_food_stock()
			var wood_stock = body.army.get_level().get_wood_stock()
			var stone_stock = body.army.get_level().get_stone_stock()
			var meets_required_goods = food_stock >= required_food and wood_stock >= required_wood and stone_stock >= required_stone

			if meets_required_goods:
				body.army.get_level().update_food_stock(-required_food)
				body.army.get_level().update_wood_stock(-required_wood)
				body.army.get_level().update_stone_stock(-required_stone)
				body.convert_to_king()
				$CollisionShape2D.set_deferred("disabled", true)
				var tween = create_tween()
				tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
				tween.finished.connect(queue_free)
				activated.emit()
