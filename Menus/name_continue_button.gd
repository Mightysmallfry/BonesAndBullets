extends Button

@export var hint : Label
@export var playerName : LineEdit
@export var NextScenePath : String = "res://Menus/main_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	
	hint.visible = false

	if NextScenePath == null || NextScenePath.is_empty():
		push_error("Missing scene assignment on continue button at " + str(get_tree_string))
	grab_focus()


func _on_pressed() -> void:
	
	if !playerName.text.is_empty():
		
		Globals.deceasedName = playerName.text;
		
		if ResourceLoader.exists(NextScenePath):
			print("Changing scene to: " + NextScenePath)
			get_tree().change_scene_to_file(NextScenePath)
		else:
			push_error("Scene does not exist: " + NextScenePath)
	else:
		hint.visible = true
		
func _on_mouse_entered() -> void:
	grab_focus()
