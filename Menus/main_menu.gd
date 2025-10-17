extends Control

@export var gameStartPath: String = "res://World/main.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UiElements/MarginContainer/VBoxContainer/StartButton.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	print("Loading Game Start")
	get_tree().change_scene_to_file(gameStartPath)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_start_button_mouse_entered() -> void:
	$UiElements/MarginContainer/VBoxContainer/StartButton.grab_focus()


func _on_quit_button_mouse_entered() -> void:
	$UiElements/MarginContainer/VBoxContainer/QuitButton.grab_focus()
