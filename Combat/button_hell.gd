extends Container

signal selected_action(action:String, target_index:int)

var _selectors_selectable:bool = false
var _main_selectable:bool = true
var _action_root = true

@onready var selectorGrid:GridContainer = $"../Main Console/HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer"

func connect_enemySelectors()->void:
	for i in range(selectorGrid.get_child_count()):
		var selector = selectorGrid.get_child(i)
		selector.connect("pressed", on_selector_pressed)
		selector.connect("hover", on_selector_hover)
		$".."._null_all_neigbors(selector.get_child(-1).get_child(-1).get_child(-1))
		#selector.enable(false)

func on_selector_hover(button:Button)->void:
	if !_selectors_selectable or Globals.IsPaused:
		return
	else:
		button.grab_focus()

func on_selector_pressed(index:int)->void:
	if !_selectors_selectable:
		return
	else:
		print(index)
		#_deselect_selectors()


func _select_selectors()->void:
	$"../Blocker".visible = false
	for i in selectorGrid.get_children():
		pass
		$".."._null_all_neigbors(i.get_child(-1).get_child(-1).get_child(-1))
		#i.enable()
	
	_selectors_selectable = true
	_main_selectable = false
	_deselect_main()
	selectorGrid.get_child(0).get_focus()
	for i in selectorGrid.get_children():
		pass
		$".."._null_all_neigbors(i.get_child(-1).get_child(-1).get_child(-1))
	print("selectable: ",selectorGrid.get_child(0).get_child(-1).get_child(-1).get_child(-1).focus_neighbor_left)
	


func _deselect_selectors()->void:
	$"../Blocker".visible = true
	for i in selectorGrid.get_children():
		i.enable(false)
	_selectors_selectable = false
	_reset_main()

func _deselect_main()->void:
	$"../Blocker2".visible = true
	disable_buttons(self)
	$"../Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Attacking".disabled = true
	$"../Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Cover".disabled = true
	$"../Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Moving".disabled = true
	$"../Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/EndTurn".disabled = true

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

# MAIN
func _on_attacking_pressed() -> void:
	_action_root = false
	self.visible = true
	$AttackActions.visible = true
	$AttackActions/MarginContainer/GridContainer/GoBack.grab_focus()


func _on_cover_pressed() -> void:
	_action_root = false
	self.visible = true
	$CoverActions.visible = true
	$CoverActions/MarginContainer/GridContainer/GoBack.grab_focus()


func _on_moving_pressed() -> void:
	_action_root = false
	self.visible = true
	$MovementActions.visible = true
	$MovementActions/MarginContainer/GridContainer/GoBack.grab_focus()


func _on_end_turn_pressed() -> void:
	selected_action.emit("end")

func _on_button_mouse_entered(source: Control) -> void:
	if Globals.IsPaused or !_main_selectable:
		return
	source.grab_focus()

func _reset_main()->void:
	$"../Blocker2".visible = true
	_action_root = true
	self.visible = false
	$AttackActions.visible = false
	$CoverActions.visible = false
	$CoverActions2.visible = false
	$MovementActions.visible = false
	$MovementActions2.visible = false
	$MovementActions3.visible = false
	$"../Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer2/GridContainer/Attacking".grab_focus()

# ATTACK OPTIONS
func _on_go_back_pressed() -> void:
	_reset_main()


func _on_aim_pressed() -> void:
	selected_action.emit("aim")
	_reset_main()


func _on_shoot_pressed() -> void:
	_select_selectors()
	pass # ENEMY SELECTOR
