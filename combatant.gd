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
var targets_in_area: Array[Combatant] = []

signal died(combatant: Combatant)
signal engaged_fight(combatant: Combatant)
signal disengaged_fight(combatant: Combatant)
signal performed_attack(combatant: Combatant)
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

func register_targeter(combatant: Combatant):
	if targeted_by.find(combatant) == -1:
		targeted_by.append(combatant)

	if not combatant.performed_attack.is_connected(receive_damage):
		combatant.performed_attack.connect(receive_damage)

func unregister_targeter(combatant: Combatant):
	targeted_by = targeted_by.filter(func(searched_combatant):return searched_combatant != combatant)

func clean_dead_targets():
	targets_in_area = targets_in_area.filter(func(target): return is_instance_valid(target))

func receive_damage(damage = 0):
	health -= damage
	received_damage.emit()
	if health <= 0:
		die()

func die():
	attack = 0
	died.emit(self)

func disengage_fight(combatant: Combatant = self, emit_disengage_signal: bool = true):
	target_combatant = null
	unregister_targeter(combatant)
	unregister_target_in_area(combatant)
	if emit_disengage_signal:
		disengaged_fight.emit(combatant)
	disconnect_signals(combatant)
	if health > 0:
		find_new_target()

func perform_attack():
	var success = attack_chance.pick_random()
	if success:
		var minimum_damage = ceil(attack*attack_minimum_modifier)
		var damage = ceil(randi_range(minimum_damage, attack)*attack_modifier)
		performed_attack.emit(damage)

func engage_fight(combatant: Combatant):
	if target_combatant: return

	target_combatant = combatant
	target_combatant.register_targeter(self)

	if not target_combatant.died.is_connected(_on_target_combatant_died):
		target_combatant.died.connect(_on_target_combatant_died)
	if not died.is_connected(target_combatant._on_targeter_combatant_died):
		died.connect(target_combatant._on_targeter_combatant_died)
	if not performed_attack.is_connected(target_combatant.receive_damage):
		performed_attack.connect(target_combatant.receive_damage)
	if not disengaged_fight.is_connected(target_combatant._on_combatant_disengaged_fighting):
		disengaged_fight.connect(target_combatant._on_combatant_disengaged_fighting)
	if not engaged_fight.is_connected(target_combatant._on_combatant_engaged_fighting):
		engaged_fight.connect(target_combatant._on_combatant_engaged_fighting)

	engaged_fight.emit(self)

func find_new_target():
	clean_dead_targets()
	if targets_in_area.size():
		var new_enemy: Combatant = targets_in_area.pick_random()
		engage_fight(new_enemy)

func valid_target(combatant: Combatant) -> bool:
	var valid = false

	var wild_minion_involved = combatant_minion and not combatant_minion.army or combatant.combatant_minion and not combatant.combatant_minion.army
	var enemy_vs_enemy = combatant_enemy and combatant.combatant_enemy
	var enemy_vs_wild_minion = (combatant.combatant_enemy or combatant_enemy) and wild_minion_involved
	var minion_vs_minion = combatant.combatant_minion and combatant_minion
	var minions_in_same_army = minion_vs_minion and combatant_minion.get_army() == combatant.combatant_minion.get_army()
	var minion_vs_enemy = (combatant.combatant_enemy and combatant_minion or combatant_enemy and combatant.combatant_minion) and not wild_minion_involved
	valid = not (wild_minion_involved or enemy_vs_enemy or enemy_vs_wild_minion) and ((minion_vs_minion and not minions_in_same_army) or minion_vs_enemy)

	return valid

func register_target_in_area(combatant: Combatant):
	targets_in_area.append(combatant)

func unregister_target_in_area(combatant: Combatant):
	targets_in_area = targets_in_area.filter(func(searched_enemy): return searched_enemy != combatant)

func _on_combatant_disengaged_fighting(combatant: Combatant):
	unregister_targeter(combatant)
	unregister_target_in_area(combatant)

	disconnect_signals(combatant)

	if target_combatant == combatant:
		target_combatant = null
		if health > 0:
			disengage_fight()

func _on_area_entered(combatant: Combatant):
	if combatant == self or not valid_target(combatant): return
	register_target_in_area(combatant)
	engage_fight(combatant)

func _on_target_combatant_died(combatant: Combatant):
	unregister_targeter(combatant)
	unregister_target_in_area(combatant)
	disengage_fight()
	disconnect_signals(combatant)

func _on_targeter_combatant_died(combatant: Combatant):
	unregister_targeter(combatant)
	unregister_target_in_area(combatant)

func _on_battle_area_area_exited(combatant: Combatant):
	if not valid_target(combatant) or combatant == self or combatant.health <= 0: return
	unregister_targeter(combatant)
	unregister_target_in_area(combatant)
	disengage_fight(combatant)

func _on_combatant_engaged_fighting(combatant: Combatant):
	engage_fight(combatant)
	register_targeter(combatant)
	register_target_in_area(combatant)

func disconnect_signals(combatant: Combatant):
	if combatant.died.is_connected(_on_target_combatant_died):
		combatant.died.disconnect(_on_target_combatant_died)
	if died.is_connected(combatant._on_targeter_combatant_died):
		died.disconnect(combatant._on_targeter_combatant_died)
	if performed_attack.is_connected(combatant.receive_damage):
		performed_attack.disconnect(combatant.receive_damage)
	if disengaged_fight.is_connected(combatant._on_combatant_disengaged_fighting):
		disengaged_fight.disconnect(combatant._on_combatant_disengaged_fighting)
	if engaged_fight.is_connected(combatant._on_combatant_engaged_fighting):
		engaged_fight.disconnect(combatant._on_combatant_engaged_fighting)
