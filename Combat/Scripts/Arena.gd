extends Node

class playerCombat:
	var health:int = Globals.playerHealth
	var bullets:int = Globals.bullets
	var cover:int = 0
	var improve_acuracy:float = 0.0
	var speed:int = Globals.combat_speed
	var aim:int = Globals.combat_aim
	var melee:int = Globals.combat_melee
	var action_points:int = floor(Globals.combat_speed / 25.0) + 2
	var reaction_point:int = 1
	var movement:int = 1

var player:playerCombat
var thisCombatEvent:CombatEvent
var players_turn:bool

const cover_chance:Array[float] = [0.0, .33, .66, .98]
const prefered_distance:Array[float] = [0.0, 10.0, 30.0, 50.0, 85.0]
const retreat_chance:Array[float] = [0.0, .33, .66, .98]

const shot_damage:int = 80

@onready var combatUI:combatControl = $Control
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	loadCombat("res://Combat/CombatEvents/CombatExample.tres")
	_process_enemies_turn()

## Loads combat resource and initalizes combatants
func loadCombat(combatScene:String)->void:
	player = playerCombat.new()
	thisCombatEvent = load(combatScene) as CombatEvent
	players_turn = thisCombatEvent.player_moves_first
	combatUI.update_player(player)
	for i in range(thisCombatEvent.enemies.size()):
		thisCombatEvent.enemies[i] = thisCombatEvent.enemies[i].duplicate(true)
		_init_enemy(thisCombatEvent.enemies[i])

## Resolves the combat
func resolveCombat()->void:
	if player.health < 1:
		return # Player dies, game over
	
	# Update player's stats
	Globals.playerHealth = player.health
	Globals.bullets = player.bullets
	
	# Update Skills
	
	# return to main
	print("CHANING SCENE")
	get_tree().change_scene_to_file("res://World/main.tscn")

## Adds variance to enemy stats
func _init_enemy(a_enemy:enemy)->void:
	var vary = func(property, variance, _min=1, _max=100)->int: return clamp(property + randi_range(-variance, variance), _min, _max)
	
	var change = vary.call(a_enemy.health, a_enemy.health_variance, 1, 9999)
	a_enemy.health = change
	a_enemy.moral = vary.call(a_enemy.moral, a_enemy.moral_variance, 1, 9999)
	
	a_enemy.speed = vary.call(a_enemy.speed, a_enemy.speed_variance)
	a_enemy.aim = vary.call(a_enemy.aim, a_enemy.aim_variance)
	a_enemy.melee = vary.call(a_enemy.melee, a_enemy.melee_variance)
	
	if thisCombatEvent.avg_starting_distance > -1:
		a_enemy.distance = thisCombatEvent.avg_starting_distance
	a_enemy.distance = vary.call(a_enemy.distance, a_enemy.distance_variance, 0, 85)
	
	a_enemy.cover = vary.call(a_enemy.cover, a_enemy.cover_variance, 0)
	combatUI.add_enemy_selector(a_enemy.name, a_enemy.health, a_enemy.distance, [_calculate_aim_chance(player, a_enemy), _calculate_aim_chance(a_enemy), _calculate_melee(a_enemy)])


## Removes enemy from combatEvent array
func _free_enemy(a_enemy:enemy)->void:
	var index:int = get_enemy_index(a_enemy)
	if index == -1:
		return
	combatUI.remove_enemy_selector(index)
	if thisCombatEvent.enemies.pop_at(index) == null || thisCombatEvent.enemies.size() == 0:
		print("YOU WIN")
		resolveCombat()

## Gets the enemy's index from combatEvent array
func get_enemy_index(a_enemy:enemy)->int:
	for i in range(thisCombatEvent.enemies.size()):
		if a_enemy == thisCombatEvent.enemies[i]:
			return i
	return -1

var _current_turn = 0
var _first:bool = true
## Processes Enemies Turn
func _process_enemies_turn()->void:
	var numberLeft:int = thisCombatEvent.enemies.size()
	if _current_turn == numberLeft:
		players_turn = true
		combatUI.update_battle_log("Your Turn!")
		return
	elif _first:
		_first = false
		var current_enemy = thisCombatEvent.enemies[_current_turn]
		current_enemy.action_points = floor(current_enemy.speed / 33.0) + 1
		if current_enemy.attack_type == 0:
			current_enemy.movement = 2
		else:
			current_enemy.movement = 1
		action(current_enemy)
		current_enemy.action_points -= 1
	else:
		var current_enemy = thisCombatEvent.enemies[_current_turn]
		action(current_enemy)
		current_enemy.action_points -= 1
		if current_enemy.action_points <= 0:
			_current_turn += 1
			_first = true
	$EnemyAction.start()

# Calculate And Generating Functions

## Calculates player win probability and damage taken by comparing the two melee skills
func _calculate_melee(a_enemy:enemy) -> float:
	return 1 / (1 + exp(.05*(a_enemy.melee - player.melee)))

## Calculates the chance for the shooter to hit the target
func _calculate_aim_chance(shooter, target=player)->float:
	if shooter is enemy:
		if shooter.attack_type == 0:
			return -1
		return (shooter.aim * max((max(20, shooter.distance)/-64.0 + 1.3125), 0)  * ((100 - (target.cover * min((shooter.distance/5.0), 1)))/100)/100)
	else:
		return min((shooter.aim * max((max(20, target.distance)/-64.0 + 1.3125), 0)  * ((100 - (target.cover * min((target.distance/5.0), 1)))/100) + player.improve_acuracy)/100, 1)

## Generate cover from a parialy skewed distribution with the mean of 40.
func _get_cover_type() -> int:
	rng.randomize()
	var raw = rng.randfn(50, 15)
	raw -= rng.randi_range(-20,0)
	if raw < 0.0:
		raw *= -1
	if raw < 10.0:
		raw += rng.randi_range(0,18)
	elif raw > 100.0:
		raw = 100.0
	return round(raw)
	

# ENEMY ACTIONS
## Damages the enemy and determines if dead
func _enemy_take_damage(a_enemy:enemy, damage:int)->void:
	a_enemy.health -= damage
	if a_enemy.health < 1:
		combatUI.update_battle_log(a_enemy.name + " died")
		_free_enemy(a_enemy)

## Enemy's action handeler
func action(acting_enemy:enemy)->void:
	rng.randomize()
	
	# cover
	if (rng.randf() < cover_chance[acting_enemy.cover_seeking] and acting_enemy.cover == 0):
		_seek_cover(acting_enemy)
		combatUI.update_battle_log(acting_enemy.name + " sought cover")
	elif (acting_enemy.movement > 0 and acting_enemy.distance > prefered_distance[acting_enemy.prefered_distance]):
		_move(acting_enemy)
		if acting_enemy.cover_seeking == 4 and acting_enemy.distance > 80:
			# Enemy retreated from battle
			combatUI.update_battle_log(acting_enemy.name + " retreated from battle")
			_free_enemy(acting_enemy)
	elif (acting_enemy.movement > 0 and acting_enemy.distance < prefered_distance[acting_enemy.prefered_distance] and rng.randf() < retreat_chance[acting_enemy.movement_reaction]):
		_move(acting_enemy, true)
	else:
		_attack(acting_enemy)
	var index = get_enemy_index(acting_enemy)
	if index != -1:
		combatUI.update_selector(index, acting_enemy.health, acting_enemy.distance, [_calculate_aim_chance(player, acting_enemy), _calculate_aim_chance(acting_enemy), _calculate_melee(acting_enemy)])

## Gets Enemey's cover
func _seek_cover(acting_enemy:enemy)->void:
	acting_enemy.cover = _get_cover_type()
	acting_enemy.action_points = max(acting_enemy.action_points -randi_range(1,4), 0)

## Move enemy relative to player
func _move(acting_enemy:enemy, away:bool=false)->void:
	acting_enemy.movement -= 1
	if !away:
		combatUI.update_battle_log(acting_enemy.name + " moved towards you")
		acting_enemy.distance = move_toward(acting_enemy.distance, prefered_distance[acting_enemy.prefered_distance], (acting_enemy.speed / 10.0))
	else:
		combatUI.update_battle_log(acting_enemy.name + " moved away from you")
		acting_enemy.distance += (acting_enemy.speed / 10.0)

## Attack player if capible
func _attack(acting_enemy:enemy)->void:
	if acting_enemy.attack_type == 1:
		if rng.randf() < _calculate_aim_chance(acting_enemy):
			combatUI.update_battle_log(acting_enemy.name + " Shot you")
			_take_damage(shot_damage)
		else:
			combatUI.update_battle_log(acting_enemy.name + " Shot at You but Missed")
		return
	elif acting_enemy.distance < 1:
		var melee = _calculate_melee(acting_enemy)
		if randf() < melee:
			# Player Wins
			combatUI.update_battle_log(acting_enemy.name + " engaged in a melee with you but you won")
			_enemy_take_damage(acting_enemy, melee * player.melee)
		else:
			# Player Loses
			combatUI.update_battle_log(acting_enemy.name + " engaged in a melee with you and beat you up")
			_take_damage(melee * acting_enemy.melee)
		return
	combatUI.update_battle_log(acting_enemy.name + " stares at you angry")


func _on_EnemyAction_timeout()->void:
	_process_enemies_turn()

# PLAYER ACTIONS
func _take_damage(damage:int)->void:
	player.health -= damage
	combatUI.update_player(player)
	if player.health < 1:
		pass

func _on_move_towards_all()->void:
	player.improve_acuracy = 0.0
	for i in thisCombatEvent.enemies:
		i.distance = max(i.distance - (player.speed / 10.0), 0)
	combatUI.update_battle_log("You Rush Towards the enemies")

func _on_move_away_all()->void:
	player.improve_acuracy = 0.0
	for i in thisCombatEvent.enemies:
		i.distance += (player.speed / 10.0)
	combatUI.update_battle_log("You run Away the enemies")

func _on_hit_deck()->void:
	player.improve_acuracy = 0.0
	player.cover = 10
	combatUI.update_battle_log("You quickly lay down on the floor")

func _on_find_cover()->void:
	player.improve_acuracy = 0.0
	_get_cover_type()

func _on_steady_aim()->void:
	player.improve_acuracy = 7.0
