extends Control
class_name combatControl
var combatLog:String = "Battle Has Begun!\n"

func update_battle_log(new_line:String)->void:
	combatLog += (new_line + "\n")
	$"Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MarginContainer/PanelContainer/MarginContainer/ScrollContainer/RichTextLabel".text = combatLog
	var scrollContainer = $"Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MarginContainer/PanelContainer/MarginContainer/ScrollContainer"
	#scrollContainer.call_deferred("scroll_vertical", scrollContainer.get_v_scroll_bar().max_value)
	await get_tree().process_frame
	scrollContainer.scroll_vertical = scrollContainer.get_v_scroll_bar().max_value

var onLeft = true
func _process(_delta: float) -> void:
	var scrollContainer = $"Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MarginContainer/PanelContainer/MarginContainer/ScrollContainer"
	var combatScrollContainer = $"../PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer"
	if Input.is_action_pressed("ui_text_scroll_up"):
		if onLeft  and scrollContainer.scroll_vertical != 0:
			scrollContainer.scroll_vertical -= 1
		elif  combatScrollContainer.scroll_vertical != 0:
			combatScrollContainer.scroll_vertical -= 1
	if Input.is_action_pressed("ui_text_scroll_down"):
		if onLeft and scrollContainer.scroll_vertical != scrollContainer.get_v_scroll_bar().max_value:
			scrollContainer.scroll_vertical += 1
		elif combatScrollContainer.scroll_vertical != combatScrollContainer.get_v_scroll_bar().max_value:
			combatScrollContainer.scroll_vertical += 1
	if Input.is_action_just_pressed("ui_scroll_left") and !onLeft:
		onLeft = true
	elif Input.is_action_just_pressed("ui_scroll_right") and onLeft:
		onLeft = false


func add_enemy_selector(enemy_name:String, health:int, distance:float, aims:Array[float])->void:
	var enemySelector = load("res://Combat/EnemySelector.tscn").instantiate()
	enemySelector.createButton(enemy_name, health, distance, aims)
	$"../PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer".add_child(enemySelector)
	_update_focus_pairs()
	$"../Container".connect_enemySelectors()

func remove_enemy_selector(index:int)->void:
	var button = $"../PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer".get_child(index)
	#$"../PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer".remove_child(button)
	button.reparent($"..")
	button.call_deferred("free")
	_update_focus_pairs()

func update_player(player:Object)->void:
	$Stats/MarginContainer/HBoxContainer/Label.text = ("Health: " + str(player.health))
	$Stats/MarginContainer/HBoxContainer/Label2.text = ("Bullets " + str(player.bullets))
	$"Point Counter/MarginContainer/HBoxContainer/Label".text = ("Action Points: " + str(player.action_points))

func update_selector(index:int, health:int, distance:float, aims:Array[float])->void:
	$"../PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer".get_child(index).update_Details(health, distance, aims)

func update_selector_theme(action:bool = true)->void:
	var container:GridContainer = $"../PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer"
	for i in container.get_children():
		i.switch_theme(action)

var battle_lines_index:int = -1
func battle_lines(index:int)->void:
	battle_lines_index = index
	var container:GridContainer = $"../PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer"
	for i in container.get_children():
		i.enable()
	container.get_children()[index].enable(false)
	scroll_focus_on(index)

func scroll_focus_on(index:int)->void:
	var combatScrollContainer = $"../PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer"
	combatScrollContainer.scroll_vertical = 110 * (ceili((index+1)/2.0) - 1)

func _update_focus_pairs()->void:
	var container:GridContainer = $"../PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer"
	var selectorNumber:int = container.get_child_count()
	for i in range(selectorNumber):
		var selector = container.get_child(i)
		var button:Button = selector.get_child(-1).get_child(-1).get_child(-1)
		if i > 0 and (i % 2) == 1:
			button.focus_neighbor_left = container.get_child(i-1).get_child(-1).get_child(-1).get_child(-1).get_path()
		if i > 1:
			button.focus_neighbor_top = container.get_child(i-2).get_child(-1).get_child(-1).get_child(-1).get_path()
		if (i+1) < selectorNumber and (i % 2) == 0:
			button.focus_neighbor_right = container.get_child(i+1).get_child(-1).get_child(-1).get_child(-1).get_path()
		if (i+2) < selectorNumber:
			button.focus_neighbor_bottom = container.get_child(i+2).get_child(-1).get_child(-1).get_child(-1).get_path()
