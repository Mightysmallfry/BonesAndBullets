extends Control

@onready var storyEventTitle: Label = get_node("%StoryEventLabel")
@onready var dialogBox: RichTextLabel = get_node("%DialogBox")
@onready var choiceList: VBoxContainer = get_node("%ChoiceList")

@export var choiceButton: PackedScene;
# we don't really need the export but it's useful for creating the resource
@export var storyEventData: StoryEventData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	clear_vbox(choiceList)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_story_event_data(data: StoryEventData) -> void:
	storyEventData = data;
	storyEventTitle.text = storyEventData.Title
	dialogBox.set_dialog(storyEventData.Dialog)
	create_choice_list()
	
func clear_vbox(vbox: VBoxContainer):
	for child in vbox.get_children():
		child.queue_free()
	
func create_choice_list() -> void:
	# Creates the list of buttons, creating a button for each associated
	# choice data given from the storyEventData
	
	# Clear Choice List
	clear_vbox(choiceList)
	
	# Add the current choices
	for choice: StoryChoice in storyEventData.Choices:
		var button: ChoiceButton = choiceButton.instantiate() as ChoiceButton
		button.choiceData = choice
		button.connect("choice_pressed", Callable(self, "_on_choice_pressed"))		
		choiceList.add_child(button)

func _on_choice_pressed(choiceData: StoryChoice):
	print("Choices have been made as: %s", choiceData.ChoiceDescription)
	# Here is where we do a switch based off of the enum

	match choiceData.ChoiceType:
		StoryChoice.ChoiceTypeEnum.CONTINUE:
			visible = false
			# Emit continue signal to resume immediately
			return
		StoryChoice.ChoiceTypeEnum.BULLET:
			print("No man outsmarts bullet")
			visible = false
			#Process effects of choice
			
			# Emit continue signal
			return
		StoryChoice.ChoiceTypeEnum.HEALTH:
			print("No man outsmarts Health")
			visible = false
			return
		StoryChoice.ChoiceTypeEnum.PROGRESS:
			print("No man outsmarts Progress")
			visible = false
			return
		StoryChoice.ChoiceTypeEnum.GAMBLE:
			print("No man outsmarts Gamble")
			visible = false
			return
