extends Container

signal selected_action(action:String, value1:int, value2:int)
var action:String

var _selectors_selectable:bool = false
var _main_selectable:bool = false
var _action_root = true
# 0 Root 1 Cover 2 Move 3 Move To 4 Move Away 5 M
var _action_tree:int = 0

@onready var selectorGrid:GridContainer = $"../PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer"

func _ready() -> void:
	_deselect_selectors()
	_deselect_main()

func connect_enemySelectors()->void:
	# I should fix this at some point
	for i in range(selectorGrid.get_child_count()):
		var selector = selectorGrid.get_child(i)
		if !selector.is_connected("pressed", on_selector_pressed):
			selector.connect("pressed", on_selector_pressed)
		if !selector.is_connected("hover", on_selector_hover):
			selector.connect("hover", on_selector_hover)
		if !selector.is_connected("focused", on_selector_focused):
			selector.connect("focused", on_selector_focused)
		selector.enable(false)

func player_turn()->void:
	_reset_main()

func on_selector_hover(button:Button)->void:
	if !_selectors_selectable or Globals.IsPaused:
		return
	else:
		button.grab_focus()

func on_selector_pressed(index:int)->void:
	if !_selectors_selectable:
		return
	else:
		_submit_action(action, index)
		_reset_main()

func on_selector_focused(index:int)->void:
	$"../Control".scroll_focus_on(index)

func _select_selectors()->void:
	$"../Blocker".visible = false
	for i in selectorGrid.get_children():
		i.enable()
	
	_selectors_selectable = true
	_main_selectable = false
	_deselect_main()
	selectorGrid.get_child(0).get_focus()

func _deselect_selectors()->void:
	$"../Blocker".visible = true
	for i in selectorGrid.get_children():
		i.enable(false)
	_selectors_selectable = false

func _deselect_main()->void:
	_main_selectable = false
	$"../Blocker2".visible = true
	for buttons:Button in $"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer".get_children():
		buttons.disabled = true
	get_viewport().gui_release_focus()
	#disable_buttons(self)

func _select_main()->void:
	_main_selectable = true
	$"../Blocker2".visible = false
	self.visible = false
	_action_root = true
	action = ""
	$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/EndTurn".disabled = false
	$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Sacrifice".disabled = false
	$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Rules".disabled = false
	if $"..".player.action_points == 0:
		$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Attacking".disabled = true
		$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Cover".disabled = true
		$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Moving".disabled = true
		$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/EndTurn".grab_focus()
	else:
		$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Attacking".disabled = false
		$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Cover".disabled = false
		$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Moving".disabled = false
		$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Attacking".grab_focus()

func disable_buttons(node, boolean = true)->void:
	for i in node.get_children(true):
		if i is Button:
			i.disabled = boolean
		elif i.get_child_count() > 0:
			disable_buttons(i)

var _backed:bool = false
func _input(_event: InputEvent) -> void:
	if _event.is_action("ui_cancel") and !_action_root and !_backed:
		_selectors_selectable = false
		_main_selectable = true
		var _action_state = _action_tree
		_reset_main()
		_action_tree = _action_state
		match _action_tree:
			0:
				pass
			1: # Cover
				_action_root = false
				_action_tree = 0
				_on_cover_pressed()
			2: # Move
				_action_root = false
				_action_tree = 0
				_on_move_2_goBack_pressed()
			3: # Move To
				_action_root = false
				_action_tree = 2
				_on_move_to_pressed()
			4: # Move Away
				_action_root = false
				_action_tree = 2
				_on_move_aw_pressed()
			5: # Shoot
				_action_root = false
				_action_tree = 0
				_on_attacking_pressed()
			_:
				pass
		_backed = true
		$"../BackButtonTimer".start()
		get_viewport().set_input_as_handled()
	if _event.is_action("ui_cancel") and _action_root and _main_selectable:
		_reset_main()

func _submit_action(taken_action:String=action, value:int=-1, second_value:int = -1)->void:
	selected_action.emit(taken_action, value, second_value)

# MAIN
func _on_attacking_pressed() -> void:
	_action_root = false
	self.visible = true
	$"../AttackActions".visible = true
	$"../AttackActions/MarginContainer/GridContainer/GoBack".grab_focus()
	if $"..".player.bullets == 0:
		$"../AttackActions/MarginContainer/GridContainer/Aim".disabled = true
		$"../AttackActions/MarginContainer/GridContainer/Shoot".disabled = true
	else:
		$"../AttackActions/MarginContainer/GridContainer/Aim".disabled = false
		$"../AttackActions/MarginContainer/GridContainer/Shoot".disabled = false
	
	if $"..".player.improve_acuracy > 0:
		$"../AttackActions/MarginContainer/GridContainer/Aim".disabled = true
	else:
		$"../AttackActions/MarginContainer/GridContainer/Aim".disabled = false
	
	var _possible_melee:bool = false
	for i in $"..".thisCombatEvent.enemies:
		if i.distance == 0:
			_possible_melee = true
			break
	if _possible_melee:
		$"../AttackActions/MarginContainer/GridContainer/Melee".disabled = false
	else:
		$"../AttackActions/MarginContainer/GridContainer/Melee".disabled = true

func _on_cover_pressed() -> void:
	_action_root = false
	self.visible = true
	$"../CoverActions".visible = true
	$"../CoverActions/MarginContainer/GridContainer/GoBack".grab_focus()
	if $"..".player.cover > 0:
		$"../CoverActions/MarginContainer/GridContainer/Deck".disabled = true
	else:
		$"../CoverActions/MarginContainer/GridContainer/Deck".disabled = false

func _on_moving_pressed() -> void:
	_action_root = false
	self.visible = true
	$"../MovementActions".visible = true
	$"../MovementActions/MarginContainer/GridContainer/GoBack".grab_focus()

func _on_end_turn_pressed() -> void:
	options = []
	ap = []
	_deselect_main()
	_submit_action("end")

func _on_button_mouse_entered(source: Control) -> void:
	if Globals.IsPaused or !_main_selectable:
		return
	source.grab_focus()

func _reset_main()->void:
	_action_tree = 0
	$"../Blocker".visible = true
	$"../AttackActions".visible = false
	$"../CoverActions".visible = false
	$"../CoverActions2".visible = false
	$"../MovementActions".visible = false
	$"../MovementActions2".visible = false
	$"../MovementActions3".visible = false
	$"../Sacrifice".visible = false
	_deselect_selectors()
	_select_main()

# ATTACK OPTIONS
func _on_go_back_pressed() -> void:
	_reset_main()

func _on_aim_pressed() -> void:
	_submit_action("aim")
	_reset_main()

func _on_shoot_pressed() -> void:
	_action_tree = 5
	action = "shoot"
	_select_selectors()

func _on_melee_pressed() -> void:
	action = "melee"
	_select_selectors()
	for i in range($"..".thisCombatEvent.enemies.size()):
		if $"..".thisCombatEvent.enemies[i].distance != 0:
			selectorGrid.get_child(i).enable(false)

# COVER OPTIONS 1
var options:Array[int] = []
var ap:Array[int] = []
func _on_find_cover_pressed() -> void:
	_action_tree = 1
	if options.is_empty():
		for i in range(4):
			options.append($".."._get_cover_type())
			ap.append(randi_range(1,4))
	
	$"../CoverActions2/MarginContainer/GridContainer/Option1".text = "cover: " + str(options[0]) + "\n A.P cost: " + str(ap[0])
	if ap[0] > $"..".player.action_points: $"../CoverActions2/MarginContainer/GridContainer/Option1".disabled = true
	else: $"../CoverActions2/MarginContainer/GridContainer/Option1".disabled = false
	$"../CoverActions2/MarginContainer/GridContainer/Option2".text = "cover: " + str(options[1]) + "\n A.P cost: " + str(ap[1])
	if ap[1] > $"..".player.action_points: $"../CoverActions2/MarginContainer/GridContainer/Option2".disabled = true
	else: $"../CoverActions2/MarginContainer/GridContainer/Option2".disabled = false
	$"../CoverActions2/MarginContainer/GridContainer/Option3".text = "cover: " + str(options[2]) + "\n A.P cost: " + str(ap[2])
	if ap[2] > $"..".player.action_points: $"../CoverActions2/MarginContainer/GridContainer/Option3".disabled = true
	else: $"../CoverActions2/MarginContainer/GridContainer/Option3".disabled = false
	$"../CoverActions2/MarginContainer/GridContainer/Option4".text = "cover: " + str(options[3]) + "\n A.P cost: " + str(ap[3])
	if ap[3] > $"..".player.action_points: $"../CoverActions2/MarginContainer/GridContainer/Option4".disabled = true
	else: $"../CoverActions2/MarginContainer/GridContainer/Option4".disabled = false
	$"../CoverActions2".visible = true
	$"../CoverActions2/MarginContainer/GridContainer/Option1".grab_focus()

func _on_deck_pressed() -> void:
	_submit_action("deck")
	_reset_main()

# COVER OPTIONS 2
func _on_cover_option_pressed(source: BaseButton) -> void:
	_submit_action("cover", int(source.text.split(" ")[1]), int(source.text.split(" ")[4]))
	_reset_main()

# MOVEMENT OPTIONS 1

func _on_move_to_pressed() -> void:
	_action_tree = 2
	$"../MovementActions2".visible = true
	$"../MovementActions2/MarginContainer/GridContainer/GoBack".grab_focus()

func _on_move_aw_pressed() -> void:
	_action_tree = 2
	$"../MovementActions3".visible = true
	var flee_distance:bool = true
	for i in $"..".thisCombatEvent.enemies:
		if i.distance < 80:
			flee_distance = false
			break
	
	if flee_distance:
		$"../MovementActions3/MarginContainer/GridContainer/Flee".disabled = false
	$"../MovementActions3/MarginContainer/GridContainer/GoBack".grab_focus()

func _on_move_2_goBack_pressed() ->void:
	$"../MovementActions2".visible = false
	$"../MovementActions3".visible = false
	$"../MovementActions".visible = true
	$"../MovementActions/MarginContainer/GridContainer/GoBack".grab_focus()

# MOVEMENT TO OPTIONS
func _on_move_all_pressed() -> void:
	_submit_action("MoveTo")
	_reset_main()

func _on_one_pressed() -> void:
	_action_tree = 3
	action = "MoveTo"
	_select_selectors()

# MOVEMENT AWAY OPTIONS
func _on_away_all_pressed() -> void:
	_submit_action("MoveAway")
	_reset_main()

func _on_oneAway_pressed() -> void:
	_action_tree = 4
	action = "MoveAway"
	_select_selectors()

func _on_flee_pressed() -> void:
	_submit_action("flee")
	_reset_main()
	_deselect_main()

# SACRIFICE OPTIONS
func _on_sacrifice_pressed() -> void:
	action = "Sacrifice"
	_action_root = false
	$"../Sacrifice".visible = true
	$"../Sacrifice/MarginContainer/GridContainer/ActionPoint".disabled = true
	$"../Sacrifice/MarginContainer/GridContainer/Health".disabled = true
	$"../Sacrifice/MarginContainer/GridContainer/Ammo".disabled = true
	
	if $"..".player.bones > 9:
		$"../Sacrifice/MarginContainer/GridContainer/ActionPoint".disabled = false
	if $"..".player.bones > 19:
		$"../Sacrifice/MarginContainer/GridContainer/Health".disabled = false
	if $"..".player.bones > 79:
		$"../Sacrifice/MarginContainer/GridContainer/Ammo".disabled = false
	$"../Sacrifice/MarginContainer/GridContainer/GoBack".grab_focus()

func _on_health_pressed() -> void:
	_submit_action(action, 0)
	_reset_main()

func _on_action_point_pressed() -> void:
	_submit_action(action, 1)
	_reset_main()

func _on_ammo_pressed() -> void:
	_submit_action(action, 2)
	_reset_main()

# RULES
func _on_rules_pressed() -> void:
	_action_root = false
	$"../RULES".visible = true
	$"../RULES/MarginContainer/VBoxContainer/Button".grab_focus()


func _on_button_pressed() -> void:
	$"../RULES".visible = false
	_reset_main()


func _on_back_button_timer_timeout() -> void:
	_backed = false
