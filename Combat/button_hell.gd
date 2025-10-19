extends Container

signal selected_action(action:String, value1:int, value2:int)
var action:String

var _selectors_selectable:bool = false
var _main_selectable:bool = true
var _action_root = true

@onready var selectorGrid:GridContainer = $"../PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer"

func _ready() -> void:
	_deselect_selectors()
	_deselect_main()

func connect_enemySelectors()->void:
	for i in range(selectorGrid.get_child_count()):
		var selector = selectorGrid.get_child(i)
		if !selector.is_connected("pressed", on_selector_pressed):
			selector.connect("pressed", on_selector_pressed)
		if !selector.is_connected("hover", on_selector_hover):
			selector.connect("hover", on_selector_hover)
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
		print(index)
		_reset_main()

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
	$"../Blocker2".visible = true
	$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Attacking".disabled = true
	$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Cover".disabled = true
	$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Moving".disabled = true
	$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/EndTurn".disabled = true
	get_viewport().gui_release_focus()
	#disable_buttons(self)

func _select_main()->void:
	$"../Blocker2".visible = false
	self.visible = false
	_action_root = true
	action = ""
	$"../Control/Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/EndTurn".disabled = false
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

func _input(_event: InputEvent) -> void:
	if _event.is_action("ui_cancel") and !_action_root:
		_selectors_selectable = false
		_main_selectable = true
		_reset_main()
		get_viewport().set_input_as_handled()

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
	$"../Blocker".visible = true
	$"../AttackActions".visible = false
	$"../CoverActions".visible = false
	$"../CoverActions2".visible = false
	$"../MovementActions".visible = false
	$"../MovementActions2".visible = false
	$"../MovementActions3".visible = false
	_deselect_selectors()
	_select_main()

# ATTACK OPTIONS
func _on_go_back_pressed() -> void:
	_reset_main()

func _on_aim_pressed() -> void:
	_submit_action("aim")
	_reset_main()

func _on_shoot_pressed() -> void:
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
	$"../MovementActions2".visible = true
	$"../MovementActions2/MarginContainer/GridContainer/GoBack".grab_focus()


func _on_move_aw_pressed() -> void:
	$"../MovementActions3".visible = true
	$"../MovementActions3/MarginContainer/GridContainer/GoBack".grab_focus()

func _on_move_2_goBack_pressed() ->void:
	$"../MovementActions2".visible = false
	$"../MovementActions3".visible = false
	$"../MovementActions/MarginContainer/GridContainer/GoBack".grab_focus()

# MOVEMENT TO OPTIONS
func _on_move_all_pressed() -> void:
	_submit_action("MoveTo")
	_reset_main()

func _on_one_pressed() -> void:
	action = "MoveTo"
	_select_selectors()

# MOVEMENT AWAY OPTIONS
func _on_away_all_pressed() -> void:
	_submit_action("MoveAway")
	_reset_main()

func _on_oneAway_pressed() -> void:
	action = "MoveAway"
	_select_selectors()
