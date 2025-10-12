extends Button
class_name ChoiceButton

@export var choiceData: StoryChoice

signal choice_pressed(data: StoryChoice)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if choiceData != null:
		text = choiceData.ChoiceDescription
	self.pressed.connect(_on_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed():
	emit_signal("choice_pressed", choiceData)
