class_name Enemy extends Area2D

func _ready():
	$Combatant.died.connect(die)
	$Combatant.disengaged_fight.connect(disengage_fight)

func die(_combatant: Combatant):
	$CollisionShape2D.set_deferred("disabled", true)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
	tween.finished.connect(queue_free)

func disengage_fight():
	$AnimationPlayer.stop()
	$AttackCooldown.stop()

func engage_fight(combatant: Combatant):
	$Combatant.engage_fight(combatant)
	$AttackCooldown.start()
	$AnimationPlayer.play("attacking")

func get_combatant_node() -> Combatant:
	return $Combatant

func _on_body_entered(enemy):
	enemy.engage_fight($Combatant)
	engage_fight(enemy.get_combatant_node())

func _on_attack_cooldown_timeout():
	$Combatant.perform_attack()
	if $Combatant.target_enemy:
		$AttackCooldown.start()
		$AnimationPlayer.play("attacking")

func _on_battle_area_body_exited(enemy):
	if enemy == $Combatant.target_enemy:
		if $Combatant.target_enemy.targeted_by.find(self) >= 0 and $Combatant.target_enemy.health > 0:
			$Combatant.target_enemy.disengage_fight()
		disengage_fight()
		$Combatant.requested_new_enemy.emit(self)

func _on_area_entered(enemy):
	if enemy.get_parent() is Minion:
		var minion: Minion = enemy.get_parent()
		minion.engage_fight(get_combatant_node())
		$Combatant.engage_fight(minion.get_combatant_node())

func _on_battle_area_area_exited(enemy):
	if enemy.get_parent() is Minion:
		var minion = enemy.get_parent()
		if minion == $Combatant.target_enemy:
			if $Combatant.target_enemy.targeted_by.find(self) >= 0 and $Combatant.target_enemy.health > 0:
				$Combatant.target_enemy.disengage_fight()
			disengage_fight()
			$Combatant.requested_new_enemy.emit(self)
