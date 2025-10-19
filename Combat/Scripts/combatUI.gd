extends Control
class_name combatControl
var combatLog:String = "Battle Has Begun!\n"

func update_battle_log(new_line:String)->void:
	combatLog += (new_line + "\n")
	$"Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MarginContainer/PanelContainer/MarginContainer/ScrollContainer/RichTextLabel".text = combatLog
	var scrollContainer = $"Main Console/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MarginContainer/PanelContainer/MarginContainer/ScrollContainer"
	scrollContainer.scroll_vertical = scrollContainer.get_v_scroll_bar().max_value

func add_enemy_selector(enemy_name:String, health:int, distance:float, aims:Array[float])->void:
	var enemySelector = load("res://Combat/EnemySelector.tscn").instantiate()
	enemySelector.createButton(enemy_name, health, distance, aims)
	$"Main Console/HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer".add_child(enemySelector)
	_update_focus_pairs()

func remove_enemy_selector(index:int)->void:
	var button = $"Main Console/HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer".get_child(index)
	$"Main Console/HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer".remove_child(button)
	button.free()
	_update_focus_pairs()

func update_player(player:Object)->void:
	$Stats/MarginContainer/HBoxContainer/Label.text = ("Health: " + str(player.health))
	$Stats/MarginContainer/HBoxContainer/Label2.text = ("Bullets " + str(player.bullets))
	$"Point Counter/MarginContainer/HBoxContainer/Label".text = ("Action Points: " + str(player.action_points))
	$"Point Counter/MarginContainer/HBoxContainer/Label2".text = ("React Points: " + str(player.reaction_point))

func update_selector(index:int, health:int, distance:float, aims:Array[float])->void:
	$"Main Console/HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer".get_child(index).update_Details(health, distance, aims)

func _update_focus_pairs()->void:
	var container:GridContainer = $"Main Console/HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/GridContainer"
	var selectorNumber:int = container.get_child_count()
	for i in range(selectorNumber):
		var selector = container.get_child(i)
		var button:Button = selector.get_child(-1).get_child(-1).get_child(-1)
		if i > 0:
			button.focus_neighbor_left = container.get_child((i-1)).get_child(-1).get_child(-1).get_path()
		if i > 2:
			button.focus_neighbor_top = container.get_child(i-3).get_child(-1).get_child(-1).get_path()
		if (i+1) < selectorNumber:
			button.focus_neighbor_right = container.get_child(i+1).get_child(-1).get_child(-1).get_path()
		if (i+3) < selectorNumber:
			button.focus_neighbor_bottom = container.get_child(i+3).get_child(-1).get_child(-1).get_path()
