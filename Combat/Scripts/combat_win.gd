extends PanelContainer


var _start_speed:int = 0
var _start_aim:int = 0
var _start_melee:int = 0

var _speed:int = 0
var _aim:int = 0
var _melee:int = 0

var _skill_points:int = 0

func _setup(skills_to_earn:int)->void:
	_start_speed = $"..".player.speed
	_start_aim = $"..".player.aim
	_start_melee = $"..".player.melee

	_speed = $"..".player.speed
	_aim = $"..".player.aim
	_melee = $"..".player.melee
	$".".visible = true
	$"MarginContainer/VBoxContainer/GridContainer/HBoxContainer/Speed-".grab_focus()
	_skill_points = skills_to_earn
	_update()

func _update_UI()->void:
	$MarginContainer/VBoxContainer/Label.text = ("Points To Alocate: " + str(_skill_points))
	$MarginContainer/VBoxContainer/GridContainer/Label.text = ("Speed: " + str(_speed))
	$MarginContainer/VBoxContainer/GridContainer/Label2.text = ("Aim: " + str(_aim))
	$MarginContainer/VBoxContainer/GridContainer/Label3.text = ("Melee: " + str(_melee))

func _on_button_mouse_entered(source: Control) -> void:
	if Globals.IsPaused:
		return
	source.grab_focus()

func _enable_pos()->void:
	if _speed < 100 and _skill_points > 0:
		$"MarginContainer/VBoxContainer/GridContainer/HBoxContainer/Speed+".disabled = false
	elif (_speed == 100 || _skill_points == 0):
		$"MarginContainer/VBoxContainer/GridContainer/HBoxContainer/Speed+".disabled = true
	if _aim < 100 and _skill_points > 0:
		$"MarginContainer/VBoxContainer/GridContainer/HBoxContainer2/Aim+".disabled = false
	elif (_aim == 100 || _skill_points == 0):
		$"MarginContainer/VBoxContainer/GridContainer/HBoxContainer2/Aim+".disabled = true
	if  _melee < 100 and _skill_points > 0:
		$"MarginContainer/VBoxContainer/GridContainer/HBoxContainer3/Melee+".disabled = false
	elif (_melee == 100 || _skill_points == 0):
		$"MarginContainer/VBoxContainer/GridContainer/HBoxContainer3/Melee+".disabled = true

func _enable_neg():
	if _speed != _start_speed:
		$"MarginContainer/VBoxContainer/GridContainer/HBoxContainer/Speed-".disabled = false
	elif _speed == _start_speed:
		$"MarginContainer/VBoxContainer/GridContainer/HBoxContainer/Speed-".disabled = true
	if _aim != _start_aim:
		$"MarginContainer/VBoxContainer/GridContainer/HBoxContainer2/Aim-".disabled = false
	elif _aim == _start_aim:
		$"MarginContainer/VBoxContainer/GridContainer/HBoxContainer2/Aim-".disabled = true
	if _melee != _start_melee:
		$"MarginContainer/VBoxContainer/GridContainer/HBoxContainer3/Melee-".disabled = false
	elif _melee == _start_melee:
		$"MarginContainer/VBoxContainer/GridContainer/HBoxContainer3/Melee-".disabled = true

func _update()->void:
	_update_UI()
	_enable_pos()
	_enable_neg()

func _on_Nspeed_pressed() -> void:
	_speed -= 1
	_skill_points += 1
	_update()


func _on_Pspeed_pressed() -> void:
	_speed += 1
	_skill_points -= 1
	_update()


func _on_Naim_pressed() -> void:
	_aim -= 1
	_skill_points += 1
	_update()


func _on_Paim_pressed() -> void:
	_aim += 1
	_skill_points -= 1
	_update()


func _on_melee_pressed() -> void:
	_melee -= 1
	_skill_points += 1
	_update()


func _on_Pmelee_pressed() -> void:
	_melee += 1
	_skill_points -= 1
	_update()


func _on_return_pressed() -> void:
	Globals.combat_speed = _speed
	Globals.combat_aim = _aim
	Globals.combat_melee = _melee
	get_tree().change_scene_to_file("res://World/main.tscn")
