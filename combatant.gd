class_name Combatant extends Area2D

@export var attack: int = 5
@export var health: int = 10
@export var miss_chances: int = 4
@export var hit_chances: int = 1
@export var battle_area_node: Area2D = null

var attack_minimum_modifier: float = 0.4
var attack_modifier: float = 1.0
var combatant_minion: Minion = null
var combatant_enemy: Enemy = null
var attack_chance := []
var target_combatant: Combatant = null
var targeted_by: Array[Combatant] = []

@warning_ignore("unused_signal")
signal died(combatant: Combatant)
signal engaged_fight(combatant: Combatant)
signal disengaged_fight(combatant: Combatant)
signal attacked(combatant: Combatant)
signal received_damage()

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
	received_damage.emit()

func die():
	attack = 0
	died.emit(self)

func disengage_fight(combatant: Combatant):
	if attacked.is_connected(combatant.receive_damage):
		attacked.disconnect(combatant.receive_damage)

	target_combatant = null

	disengaged_fight.emit(self)

	if disengaged_fight.is_connected(combatant._on_combatant_disengaged_fight):
		disengaged_fight.disconnect(combatant._on_combatant_disengaged_fight)

func disconnect_signals():
	if target_combatant:
		if attacked.is_connected(target_combatant.receive_damage):
			pass

func perform_attack():
	var success = attack_chance.pick_random()
	if success:
		var minimum_damage = ceil(attack*attack_minimum_modifier)
		var damage = ceil(randi_range(minimum_damage, attack)*attack_modifier)
		attacked.emit(damage)

func engage_fight(combatant: Combatant):
	if not target_combatant:
		target_combatant = combatant
		target_combatant.targeted_by.append(self)

		if combatant.combatant_enemy:
			combatant.engage_fight(self)

		if not attacked.is_connected(combatant.receive_damage):
			attacked.connect(combatant.receive_damage)
		if not disengaged_fight.is_connected(combatant._on_combatant_disengaged_fight):
			disengaged_fight.connect(combatant._on_combatant_disengaged_fight)

	engaged_fight.emit(self)

func find_new_target():
	if get_overlapping_areas().size():
		var available_enemies := get_overlapping_areas()
		if battle_area_node:
			available_enemies.append_array(battle_area_node.get_overlapping_areas())
		available_enemies = available_enemies.filter(
			func(enemy: Combatant):
				var are_minions_in_different_armies = (combatant_minion and enemy.combatant_minion and combatant_minion.army != enemy.combatant_minion.army)
				var is_enemy_vs_minion = (combatant_enemy and enemy.combatant_minion or combatant_minion and enemy.combatant_enemy)
				var new_target_is_alive = enemy.health >= 0
				return (are_minions_in_different_armies or is_enemy_vs_minion) and new_target_is_alive)

		if available_enemies.size():
			var new_enemy: Combatant = available_enemies.pick_random()
			engage_fight(new_enemy)

func _on_combatant_disengaged_fight(combatant: Combatant):
	targeted_by = targeted_by.filter(func(enemy):return enemy != combatant)
	if target_combatant == combatant:
		target_combatant = null
		disengage_fight(combatant)
		find_new_target()

func _on_area_entered(combatant: Combatant):
	var self_is_wild_minion = combatant_minion and not combatant_minion.army
	if target_combatant or self_is_wild_minion : return

	if combatant.combatant_enemy:
		if combatant_minion and combatant_minion.army:
			engage_fight(combatant)

	if combatant.combatant_minion:
		var combatant_entity := combatant.combatant_minion

		var combatant_is_in_same_army = combatant_minion and combatant_entity.get_army() == combatant_minion.get_army()
		var combatant_is_wild_minion = not combatant_entity.get_army()

		var can_fight = not combatant_is_in_same_army and not combatant_is_wild_minion
		if can_fight:
			engage_fight(combatant)

func _on_battle_area_area_exited(combatant: Combatant):
	if combatant == target_combatant:
		disengage_fight(combatant)
