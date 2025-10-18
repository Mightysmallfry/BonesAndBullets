extends Button
class_name ChoiceButton

@export var choiceData: StoryChoice

signal choice_pressed(data: StoryChoice)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if choiceData != null:
		text = choiceData.choiceDescription
	self.pressed.connect(_on_pressed)
	_find_focus_order()
	self.mouse_entered.connect(_on_mouse_entered)
	

## Sets the first option as the focus, populates choices above and bellow as next/before options
func _find_focus_order() ->void:
	if get_parent() == null:
		printerr("Orphan Choice Button Error!")
		return
	
	var _choiceList:VBoxContainer = get_parent()
	var myIndex:int = get_index()
	if myIndex == 0:
		self.grab_focus()
	else:
		self.focus_neighbor_top = _choiceList.get_child(myIndex -1).get_path()
	if get_index() < _choiceList.get_child_count()-1:
		self.focus_neighbor_bottom = _choiceList.get_child(myIndex + 1).get_path()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_pressed():
	emit_signal("choice_pressed", choiceData)

func _on_mouse_entered()->void:
	grab_focus()
	pass
