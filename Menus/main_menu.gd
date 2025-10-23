extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.time_scale = 1
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_quit_button_mouse_entered() -> void:
	$UiElements/MarginContainer/VBoxContainer/QuitButton.grab_focus()

func _on_mouse_entered() -> void:
	pass # Replace with function body.


func _on_music_timer_timeout() -> void:
	$"[titleTheme]ICarryTheseBones".play()
