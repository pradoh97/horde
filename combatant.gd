class_name Combatant extends Node

@export var combatant_entity: Node2D = null
@export var attack: int = 5
@export var health: int = 10
@export var miss_chances: int = 4
@export var hit_chances: int = 1

var attack_chance := []
var target_enemy: Combatant = null
var targeted_by: Array[Combatant] = []

@warning_ignore("unused_signal")
signal died(combatant: Combatant)
signal engaged_fight(combatant: Combatant)
signal requested_new_enemy(combatant: Combatant)
signal disengaged_fight(combatant: Combatant)
signal attacked(combatant: Combatant)

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

func disengage_fight():
	disengaged_fight.emit(self)

	if target_enemy:
		if attacked.is_connected(target_enemy.receive_damage):
			attacked.disconnect(target_enemy.receive_damage)
		if requested_new_enemy.is_connected(target_enemy._on_enemy_requested_new_enemy):
			requested_new_enemy.disconnect(target_enemy._on_enemy_requested_new_enemy)

	target_enemy = null

func disconnect_signals():
	if target_enemy:
		if attacked.is_connected(target_enemy.receive_damage):
			pass

func perform_attack():
	var success = attack_chance.pick_random()
	if success:
		attacked.emit(randi_range(ceil(attack*0.4), attack))

func engage_fight(combatant: Combatant):
	if not target_enemy:
		target_enemy = combatant
		if not attacked.is_connected(target_enemy.receive_damage):
			attacked.connect(target_enemy.receive_damage)
		target_enemy.targeted_by.append(self)

func _on_combatant_disengaged_fight(combatant: Combatant):
	targeted_by = targeted_by.filter(func(enemy):return enemy != combatant)
	if target_enemy == combatant:
		target_enemy = null
		disengage_fight()
