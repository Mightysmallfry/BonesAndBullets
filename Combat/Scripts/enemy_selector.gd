extends MarginContainer

signal pressed(index:int)
signal hover(button:Button)
signal focused(index:int)

func createButton(_name:String, health:int, distance:float, aims:Array[float])->void:
	$PanelContainer/MarginContainer/VBoxContainer/ProgressBar.max_value = health
	$PanelContainer/MarginContainer/VBoxContainer/Label.text = _name
	update_Details(health,distance, aims)

func update_Details(health:int, distance:float, aims:Array[float])->void:
	$PanelContainer/MarginContainer/VBoxContainer/ProgressBar.value = health
	$PanelContainer/MarginContainer/VBoxContainer/ProgressBar/Label.text = str(health)
	$PanelContainer/MarginContainer/VBoxContainer/Label2.text = ("Distance: " + str(distance))
	$PanelContainer/MarginContainer/VBoxContainer/Label3.text = ("My shot odds: " + str(snapped(aims[0], .001)*100) + "%")
	if aims[1] != -1:
		$PanelContainer/MarginContainer/VBoxContainer/Label4.text = ("Thier shot odds: " + str(snapped(aims[1], .001)*100) + "%")
	else:
		$PanelContainer/MarginContainer/VBoxContainer/Label4.text = ""
	$PanelContainer/MarginContainer/VBoxContainer/Label5.text = ("My melee odds: " + str(snapped(aims[2], .001)*100) + "%")

func switch_theme(action:bool)->void:
	if action:
		$PanelContainer/MarginContainer/Control.theme = load("res://Combat/Scripts/Moves.tres")
	else:
		$PanelContainer/MarginContainer/Control.theme = load("res://Combat/Scripts/Selector.tres")

func get_focus():
	$PanelContainer/MarginContainer/Control.grab_focus()

func _on_control_pressed() -> void:
	pressed.emit(get_index())


func _on_control_mouse_entered() -> void:
	hover.emit($PanelContainer/MarginContainer/Control)

func enable(boolean:bool = true)->void:
	$PanelContainer/MarginContainer/Control.disabled = !boolean


func _on_control_focus_entered() -> void:
	focused.emit(get_index())
