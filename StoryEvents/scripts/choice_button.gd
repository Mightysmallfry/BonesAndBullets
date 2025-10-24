extends Button
class_name ChoiceButton

@export var choiceData: StoryChoice

signal choice_pressed(data: StoryChoice)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_find_focus_order()
	if choiceData != null:
		text = choiceData.choiceDescription
		if _resource_Dependent():
			print(disabled)
			self.disabled = true
			print(disabled)
		else:
			print("NAH")
	self.pressed.connect(_on_pressed)
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

func _resource_Dependent()->bool:
	if choiceData.rewards.size() == 0.0:
		return false
	
	match choiceData.requresResource:
		choiceData.resource.NONE:
			return false
		choiceData.resource.BULLET:
			if Globals.bullets == 0.0:
				return true
			return false
		choiceData.resource.BONE:
			if Globals.currentBones == 0.0:
				return true
			return false
		_:
			return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_pressed():
	emit_signal("choice_pressed", choiceData)

func _on_mouse_entered()->void:
	grab_focus()
