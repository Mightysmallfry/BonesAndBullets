extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	
	if event.is_action_pressed("pause"):
		Globals.IsPaused = !Globals.IsPaused
		
		if Globals.IsPaused:
			Engine.time_scale = 0
			get_tree().paused = true
			visible = true
		else: 
			Engine.time_scale = 1
			get_tree().paused = false
			visible = false
		get_tree().root.get_viewport().set_input_as_handled()

func _on_resume_button_pressed() -> void:
	Engine.time_scale = 1
	get_tree().paused = false
	visible = false;

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_resume_button_mouse_entered() -> void:
	$PanelContainer/MarginContainer/VBoxContainer/ResumeButton.grab_focus()


func _on_quit_button_mouse_entered() -> void:
	$PanelContainer/MarginContainer/VBoxContainer/QuitButton.grab_focus()
