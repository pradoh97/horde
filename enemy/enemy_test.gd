class_name Enemy extends Area2D

@export var attack: int = 5
@export var health: int = 10
@export var miss_chances: int = 4
@export var hit_chances: int = 1
var attack_chance := []
var target_enemy: Minion = null
@warning_ignore("unused_signal")

signal died(enemy)
signal requested_new_enemy(enemy)
signal attacked

func _ready():
	var chances := []
	chances.resize(miss_chances)
	chances.fill(0)
	attack_chance.append_array(chances)
	chances.resize(hit_chances)
	chances.fill(1)
	attack_chance.append_array(chances)
	attack_chance.shuffle()

func receive_damage(damage = 0):
	health -= damage
	if health <= 0:
		die()

func die():
	attack = 0
	died.emit(self)
	disengage_fight()
	$CollisionShape2D.set_deferred("disabled", true)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
	tween.finished.connect(queue_free)

func perform_attack():
	var success = attack_chance.pick_random()
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
	if target_enemy:
		if attacked.is_connected(target_enemy.receive_damage):
			attacked.disconnect(target_enemy.receive_damage)
		if requested_new_enemy.is_connected(target_enemy._on_enemy_requested_new_enemy):
			requested_new_enemy.disconnect(target_enemy._on_enemy_requested_new_enemy)
		target_enemy.targeted_by = target_enemy.targeted_by.filter(func(enemy):return enemy != self)
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
		if target_enemy.targeted_by.find(self) >= 0 and target_enemy.health > 0:
			target_enemy.disengage_fight()
		disengage_fight()
		requested_new_enemy.emit(self)


func _on_area_entered(area):
	if area.get_parent() is Minion:
		var minion: Minion = area.get_parent()
		minion.engage_fight(self)
		engage_fight(minion)


func _on_battle_area_area_exited(area):
	if area.get_parent() is Minion:
		var body = area.get_parent()
		if body == target_enemy:
			if target_enemy.targeted_by.find(self) >= 0 and target_enemy.health > 0:
				target_enemy.disengage_fight()
			disengage_fight()
			requested_new_enemy.emit(self)
