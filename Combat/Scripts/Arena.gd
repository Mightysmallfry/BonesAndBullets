extends Node

class playerCombat:
	var health:int = Globals.playerHealth
	var bullets:int = Globals.bullets
	var bones:int = Globals.startingBones
	var cover:int = 0
	var improve_acuracy:float = 0.0
	var speed:int = Globals.combat_speed
	var aim:int = Globals.combat_aim
	var melee:int = Globals.combat_melee
	var action_points:int = floor(Globals.combat_speed / 25.0) + 2

var skills_to_earn:int = 0

var player:playerCombat
var thisCombatEvent:CombatEvent
var players_turn:bool

const cover_chance:Array[float] = [0.0, .33, .66, .98]
const prefered_distance:Array[float] = [0.0, 10.0, 30.0, 50.0, 85.0]
const retreat_chance:Array[float] = [0.0, .33, .66, .98]


@onready var _move_sound:AudioStreamMP3 = preload("res://Assets/SFX/SnowRun.mp3")
@onready var _shot_hit_sound:AudioStreamMP3 = preload("res://Assets/SFX/ShotHit.mp3")
@onready var _shot_miss_sound:AudioStreamMP3 = preload("res://Assets/SFX/ShotMiss.mp3")
@onready var _cover_sound:AudioStreamMP3 = preload("res://Assets/SFX/Cover.mp3")
@onready var _melee_sound:AudioStreamMP3 = preload("res://Assets/SFX/melee.mp3")



var combatEventPath:String = "res://Combat/CombatEvents/CombatExample.tres"
#var combatEventPath:String

@onready var combatUI:combatControl = $Control
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	if thisCombatEvent != null:
		loadCombat()
	else:
		thisCombatEvent = load(combatEventPath) as CombatEvent
		loadCombat()

var end:bool = false
func _on_buffer_timeout()->void:
	if !end:
		beginCombat()
	else:
		if player.health < 1:
			get_tree().change_scene_to_file("res://Menus/end_menu.tscn")
		else:
			print(skills_to_earn)
			$WIN._setup(skills_to_earn)

## Loads combat resource and initalizes combatants
func loadCombat()->void:
	player = playerCombat.new()
	players_turn = thisCombatEvent.player_moves_first
	combatUI.update_player(player)
	for i in range(thisCombatEvent.enemies.size()):
		thisCombatEvent.enemies[i] = thisCombatEvent.enemies[i].duplicate(true)
		_init_enemy(thisCombatEvent.enemies[i])
	$AnimationPlayer.play("fade")
	$BufferTimer.start()

func beginCombat()->void:
	if players_turn:
		_start_turn()
	else:
		combatUI.update_selector_theme(true)
		_process_enemies_turn()

## Resolves the combat
func resolveCombat()->void:
	end = true
	if player.health < 1:
		$BufferTimer.start(4.0)
		return
	
	# Update player's stats
	Globals.playerHealth = player.health
	Globals.bullets = player.bullets
	Globals.startingBones = player.bones
	
	print("WIN")
	$BufferTimer.start()
	

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
	
	if thisCombatEvent.avg_starting_cover > -1:
		a_enemy.cover = thisCombatEvent.avg_starting_cover
	a_enemy.cover = vary.call(a_enemy.cover, a_enemy.cover_variance, 0)
	combatUI.add_enemy_selector(a_enemy.name, a_enemy.health, a_enemy.distance, [_calculate_aim_chance(player, a_enemy), _calculate_aim_chance(a_enemy), _calculate_melee(a_enemy)])


## Removes enemy from combatEvent array
func _free_enemy(a_enemy:enemy)->void:
	var index:int = get_enemy_index(a_enemy)
	if index == -1:
		return
	skills_to_earn += floor((a_enemy.health/101.0) + (a_enemy.speed/50.0) + (a_enemy.aim/50.0) + (a_enemy.melee/50.0))
	for i in thisCombatEvent.enemies:
			i.moral -= 10

	combatUI.remove_enemy_selector(index)
	if thisCombatEvent.enemies.pop_at(index) == null || thisCombatEvent.enemies.size() == 0:
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
	if player.health < 1:
		return
	var numberLeft:int = thisCombatEvent.enemies.size()
	if _current_turn == numberLeft:
		players_turn = true
		_start_turn()
		return
	elif _first:
		_first = false
		var current_enemy = thisCombatEvent.enemies[_current_turn]
		current_enemy.action_points = floor(current_enemy.speed / 33.0) + 1
		if current_enemy.attack_type == 0:
			current_enemy.movement = 2
		else:
			current_enemy.movement = 1
		combatUI.battle_lines(_current_turn)
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
		var hit_probability = shooter.aim / 100.0 # base aim
		hit_probability *= (max((max(20, shooter.distance)/-64.0 + 1.3125), 0)) # distance
		var cover_falloff = 5.0
		var cover_effect = target.cover * (1 - exp(-shooter.distance / cover_falloff))
		var cover_factor = clamp((100 - cover_effect) / 100.0, 0, 1) 
		return hit_probability * cover_factor
	else:
		var hit_probability = shooter.aim / 100.0 # base aim
		hit_probability *= max((target.distance/-64.0 + 1.3125), 0) # distance
		var cover_falloff = 5.0
		var cover_effect = target.cover * (1 - exp(-target.distance / cover_falloff))
		var cover_factor = clamp((100 - cover_effect) / 100.0, 0, 1) 
		hit_probability *= cover_factor
		return min(hit_probability + (player.improve_acuracy/100.0), 1)

## Generate cover from a parialy skewed distribution with the mean of 40.
func _get_cover_type() -> int:
	rng.randomize()
	var raw = rng.randfn(50, 15)
	raw += rng.randi_range(-40,0)
	if raw < 0.0:
		raw *= -1
	if raw < 10.0:
		raw += rng.randi_range(0,30)
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
	else:
		_update_enemy_selector(get_enemy_index(a_enemy))

func _update_all_enemy_selectors()->void:
	for i in thisCombatEvent.enemies:
		combatUI.update_selector(get_enemy_index(i), i.health, i.distance, [_calculate_aim_chance(player, i), _calculate_aim_chance(i), _calculate_melee(i)])

func _update_enemy_selector(index:int)->void:
	combatUI.update_selector(index, thisCombatEvent.enemies[index].health, thisCombatEvent.enemies[index].distance, [_calculate_aim_chance(player, thisCombatEvent.enemies[index]), _calculate_aim_chance(thisCombatEvent.enemies[index]), _calculate_melee(thisCombatEvent.enemies[index])])

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
	$AudioStreamPlayer2D.stream = _cover_sound
	$AudioStreamPlayer2D.play()

## Move enemy relative to player
func _move(acting_enemy:enemy, away:bool=false)->void:
	acting_enemy.movement -= 1
	$AudioStreamPlayer2D.stream = _move_sound
	$AudioStreamPlayer2D.play()
	if !away:
		combatUI.update_battle_log(acting_enemy.name + " moved towards You")
		acting_enemy.distance = move_toward(acting_enemy.distance, prefered_distance[acting_enemy.prefered_distance], (acting_enemy.speed / 10.0))
	else:
		combatUI.update_battle_log(acting_enemy.name + " moved away from You")
		acting_enemy.distance += (acting_enemy.speed / 10.0)

## Attack player if capible
func _attack(acting_enemy:enemy)->void:
	if acting_enemy.attack_type == 1:
		if rng.randf() < _calculate_aim_chance(acting_enemy):
			var bullet_damage:int = randi_range(40,80)
			combatUI.update_battle_log(acting_enemy.name + " shot You for " + str(bullet_damage) + " health")
			_take_damage(bullet_damage)
			$AudioStreamPlayer2D.stream = _shot_hit_sound
		else:
			combatUI.update_battle_log(acting_enemy.name + " shot at You but missed")
			$AudioStreamPlayer2D.stream = _shot_miss_sound
		$AudioStreamPlayer2D.play()
		return
	elif acting_enemy.distance < 1:
		var melee = _calculate_melee(acting_enemy)
		if randf() < melee:
			# Player Wins
			var damage:int = round(melee * player.melee)
			combatUI.update_battle_log(acting_enemy.name + " engaged in a melee with You but You won, causing " + str(damage) + " damage")
			_enemy_take_damage(acting_enemy, damage)
		else:
			# Player Loses
			var damage:int = round(melee * acting_enemy.melee)
			combatUI.update_battle_log(acting_enemy.name + " engaged in a melee with You and beat You up causing " + str(damage) + " damage")
			_take_damage(damage)
		$AudioStreamPlayer2D.stream = _melee_sound
		$AudioStreamPlayer2D.play()
		return
	combatUI.update_battle_log(acting_enemy.name + " stares at You angry")


func _on_EnemyAction_timeout()->void:
	_process_enemies_turn()

# PLAYER ACTIONS
func _take_damage(damage:int)->void:
	player.health -= damage
	Globals.totalHealthLost += damage
	combatUI.update_player(player)
	if player.health < 1:
		combatUI.update_battle_log("You Died")
		$AnimationPlayer.play("Death")
		resolveCombat()
func _start_turn()->void:
	combatUI.update_selector_theme(false)
	player.action_points = floor(Globals.combat_speed / 25.0) + 2
	$Container.player_turn()
	combatUI.update_player(player)
	combatUI.update_battle_log("Your Turn!")

func _on_action_submitted(selected_action: String, value1: int, value2: int) -> void:
	match (selected_action):
		"end":
			combatUI.update_selector_theme(true)
			players_turn = false
			_current_turn = 0
			_process_enemies_turn()
		"aim":
			player.action_points -= 1
			_steady_aim()
			_update_all_enemy_selectors()
		"shoot":
			player.action_points -= 1
			_shoot(value1)
		"melee":
			player.action_points -= 1
			_melee(value1)
		"deck":
			player.action_points -= 1
			_hit_deck()
			_update_all_enemy_selectors()
		"cover":
			_find_cover(value1, value2)
			_update_all_enemy_selectors()
		"MoveTo":
			player.action_points -= 1
			player.cover = 0
			player.improve_acuracy = 0
			$AudioStreamPlayer2D.stream = _move_sound
			$AudioStreamPlayer2D.play()
			if value1 == -1:
				_move_towards_all()
				_update_all_enemy_selectors()
			else:
				_move_towards(value1)
				_update_enemy_selector(value1)
		"MoveAway":
			player.action_points -= 1
			player.cover = 0
			player.improve_acuracy = 0
			$AudioStreamPlayer2D.stream = _move_sound
			$AudioStreamPlayer2D.play()
			if value1 == -1:
				_move_away_all()
				_update_all_enemy_selectors()
			else:
				_move_away(value1)
				_update_enemy_selector(value1)
		"Sacrifice":
			match value1:
				0:
					player.bones -= 20
					player.health += 10
					Globals.totalHealthGained += 10
				1:
					player.bones -= 10
					player.action_points += 1
				2:
					player.bones -= 80
					player.bullets += 1
				_:
					printerr("ERROR: UNKNOWN SACRIFICE VALUE")
		"flee":
			combatUI.update_battle_log("You escaped the battle")
			$AudioStreamPlayer2D.stream = _move_sound
			$AudioStreamPlayer2D.play()
			resolveCombat()
	combatUI.update_player(player)

func _move_towards_all()->void:
	player.improve_acuracy = 0.0
	for i in thisCombatEvent.enemies:
		i.distance = move_toward(i.distance, 0, (player.speed / 10.0))
	combatUI.update_battle_log("You rush towards the enemies")

func _move_towards(index:int)->void:
	combatUI.update_battle_log("You rush towards " + thisCombatEvent.enemies[index].name)
	thisCombatEvent.enemies[index].distance = move_toward(thisCombatEvent.enemies[index].distance, 0, (player.speed / 10.0))

func _move_away_all()->void:
	player.improve_acuracy = 0.0
	for i in thisCombatEvent.enemies:
		i.distance += (player.speed / 10.0)
	combatUI.update_battle_log("You run away the enemies")

func _move_away(index:int)->void:
	combatUI.update_battle_log("You run away from " + thisCombatEvent.enemies[index].name)
	thisCombatEvent.enemies[index].distance += (player.speed / 10.0)

func _shoot(index:int)->void:
	player.bullets -= 1
	Globals.totalBulletsUsed -= 1
	if rng.randf() < _calculate_aim_chance(player, thisCombatEvent.enemies[index]):
		var bullet_damage:int = randi_range(40,80)
		combatUI.update_battle_log("You shoot " + thisCombatEvent.enemies[index].name + " for " + str(bullet_damage) + " health")
		_enemy_take_damage(thisCombatEvent.enemies[index], bullet_damage)
		$AudioStreamPlayer2D.stream = _shot_hit_sound
	else:
		combatUI.update_battle_log("You shoot at " + thisCombatEvent.enemies[index].name + " but missed!")
		$AudioStreamPlayer2D.stream = _shot_miss_sound
	$AudioStreamPlayer2D.play()
		

func _melee(index:int)->void:
	var melee = _calculate_melee(thisCombatEvent.enemies[index])
	if rng.randf() < melee:
		# Player Wins
		var damage:int = round(melee * player.melee)
		combatUI.update_battle_log("You engaged " + thisCombatEvent.enemies[index].name + " in a melee and won, causing " + str(damage) + " damage")
		_enemy_take_damage(thisCombatEvent.enemies[index], damage)
	else:
		# Player Loses
		var damage:int = round(thisCombatEvent.enemies[index].melee)
		combatUI.update_battle_log("You engaged " + thisCombatEvent.enemies[index].name + " in a melee but beat you up, causing " + str(damage) + " damage")
		_take_damage(melee * damage)
	pass

func _hit_deck()->void:
	player.improve_acuracy = 0.0
	player.cover = 20
	combatUI.update_battle_log("You quickly lay down on the floor")

func _find_cover(cover:int, action_points_spent:int)->void:
	combatUI.update_battle_log("You find and take cover")
	player.cover = cover
	player.action_points -= action_points_spent
	$AudioStreamPlayer2D.stream = _cover_sound
	$AudioStreamPlayer2D.play()

func _steady_aim()->void:
	combatUI.update_battle_log("You take a breath and steady your aim")
	player.improve_acuracy = 7.0
