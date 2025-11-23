extends Area2D

@export var attack: int = 5
@export var health: int = 10

func receive_damage(damage: int = 0):
	health -= damage
	if health <= 0:
		die()

func die():
	attack = 0
	$CollisionShape2D.set_deferred("disabled", true)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
	tween.finished.connect(queue_free)


func _on_body_entered(minion: Minion):
	minion.engage_fight(self)
