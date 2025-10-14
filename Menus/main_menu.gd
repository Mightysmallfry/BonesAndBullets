extends Control

@export var gameStartPath: String = "res://World/main.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	print("Loading Game Start")
	get_tree().change_scene_to_file(gameStartPath)
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
