class_name Enemy extends Area2D

@export var attack: int = 5
@export var health: int = 10
var target_enemy: Minion = null
@warning_ignore("unused_signal")

signal died(enemy)
signal requested_new_enemy(enemy)
signal attacked

func receive_damage(damage: int = 0):
	health -= damage
	if health <= 0:
		die()

func die():
	attack = 0
	died.emit(self)
	$CollisionShape2D.set_deferred("disabled", true)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
	tween.finished.connect(queue_free)

func perform_attack():
	var success = [0, 0, 0, 1].pick_random()
	if success:
		attacked.emit(randi_range(ceil(attack*0.4), attack))

func engage_fight(minion: Minion):
	if not target_enemy:
		$AttackCooldown.start()
		$AnimationPlayer.play("attacking")
		target_enemy = minion
		if not attacked.is_connected(target_enemy.receive_damage):
			attacked.connect(target_enemy.receive_damage)
		target_enemy.targeted_by.append(self)

func disengage_fight():
	$AnimationPlayer.stop()
	$AttackCooldown.stop()
	requested_new_enemy.disconnect(target_enemy._on_enemy_requested_new_enemy)
	target_enemy.targeted_by.erase(self)
	target_enemy = null

func _on_body_entered(minion: Minion):
	minion.engage_fight(self)
	engage_fight(minion)

func _on_attack_cooldown_timeout():
	perform_attack()
	if target_enemy:
		$AttackCooldown.start()
		$AnimationPlayer.play("attacking")

func _on_battle_area_body_exited(body):
	if body == target_enemy:
		if target_enemy.targeted_by.find(self) >= 0:
			target_enemy.disengage_fight()
			disengage_fight()
			requested_new_enemy.emit(self)
