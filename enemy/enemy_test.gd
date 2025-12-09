class_name Enemy extends Area2D

@export var combatant_node: Combatant = null

func _ready():
	if combatant_node:
		combatant_node.died.connect(die)
		combatant_node.disengaged_fight.connect(disengage_fight)
		combatant_node.combatant_enemy = self
		combatant_node.engaged_fight.connect(engage_fight)

func die(_combatant: Combatant):
	combatant_node.disengaged_fight.disconnect(disengage_fight)
	$CollisionShape2D.set_deferred("disabled", true)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
	tween.finished.connect(queue_free)

func disengage_fight(_combatant: Combatant):
	$AnimationPlayer.stop()
	$AttackCooldown.stop()

func engage_fight(_combatant: Combatant):
	attack()

func attack():
	if combatant_node.target_combatant:
		$AttackCooldown.start()
		$AnimationPlayer.play("attacking")

func get_combatant_node() -> Combatant:
	return combatant_node

func _on_attack_cooldown_timeout():
	combatant_node.perform_attack()
	attack()
