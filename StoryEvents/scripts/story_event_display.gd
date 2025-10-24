extends Control

@onready var storyEventTitle: RichTextLabel = get_node("%StoryEventLabel")
@onready var dialogBox: RichTextLabel = get_node("%DialogBox")
@onready var choiceList: VBoxContainer = get_node("%ChoiceList")

@export var choiceButton: PackedScene;
# we don't really need the export but it's useful for creating the resource
@export var storyEventData: StoryEventData


signal finished_story_event

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	clear_vbox(choiceList)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func load_story_event_data(data: StoryEventData) -> void:
	storyEventData = data;
	storyEventTitle.text = "[b]Travel Log:[/b] Day %s : " %Globals.currentDay + storyEventData.title
	dialogBox.set_dialog(storyEventData.dialog)
	create_choice_list()
	
func clear_vbox(vbox: VBoxContainer):
	for child in vbox.get_children():
		# added this for the auto focus to work
		vbox.remove_child(child)
		child.queue_free()
	
func create_choice_list() -> void:
	# Creates the list of buttons, creating a button for each associated
	# choice data given from the storyEventData
	
	# Clear Choice List
	clear_vbox(choiceList)
	
	# Add the current choices
	for choice: StoryChoice in storyEventData.choices:
		var button: ChoiceButton = choiceButton.instantiate() as ChoiceButton
		button.choiceData = choice
		button.connect("choice_pressed", Callable(self, "_on_choice_pressed"))		
		choiceList.add_child(button)

func _on_choice_pressed(choiceData: StoryChoice):
	print("Choices have been made as: " + choiceData.choiceDescription)
	# Here is where we do a switch based off of the enum
	if choiceData.rewards == null or choiceData.rewards.size() == 0:
		finish_story_event()
		
	for rewards in choiceData.rewards:
		match rewards.rewardType:
			rewards.ChoiceTypeEnum.CONTINUE:
				finish_story_event()
				# Emit continue signal to resume immediately
				return
			rewards.ChoiceTypeEnum.BULLET:
				print("No man outsmarts bullet")
				Globals.bullets += rewards.rewardValue;
				if rewards.rewardValue > 0:
					Globals.totalBulletsFound += rewards.rewardValue
				else:
					Globals.totalBulletsUsed += rewards.rewardValue
				clamp(Globals.bullets, 0, Globals.maxBullets)
				finish_story_event()
				# Emit continue signal
				return
			rewards.ChoiceTypeEnum.HEALTH:
				print("No man outsmarts Health")
				Globals.playerHealth += rewards.rewardValue;
				Globals.playerHealth = clamp(Globals.playerHealth, 0, Globals.maxHealth)
				if rewards.rewardValue > 0:
					Globals.totalHealthGained += rewards.rewardValue
				else:
					Globals.totalHealthLost += rewards.rewardValue
				if Globals.playerHealth == 0:
					get_tree().change_scene_to_file("res://Menus/end_menu.tscn")
				finish_story_event()
				return
			rewards.ChoiceTypeEnum.PROGRESS:
				print("No man outsmarts Progress")
				Globals.current_time = %StoryProgressionTimer.time_left
				Globals.current_time -= rewards.rewardValue
				finish_story_event()
				return
			rewards.ChoiceTypeEnum.GAMBLE:
				print("No man outsmarts Gamble")
				finish_story_event()
				return
			rewards.ChoiceTypeEnum.NEXT:
				load_story_event_data(rewards.nextEvent)
				return
			rewards.ChoiceTypeEnum.COMBAT:
				var arena = load("res://Combat/Arena.tscn").instantiate()
				arena.thisCombatEvent = rewards.combatPath
				Globals.current_time = %StoryProgressionTimer.time_left
				var current = get_tree().current_scene
				get_tree().root.add_child(arena)
				get_tree().current_scene = arena
				current.queue_free()
				return
			rewards.ChoiceTypeEnum.BONE:
				if Globals.currentBones > 0:
					Globals.currentBones += rewards.rewardValue
					Globals.currentBones = clamp(Globals.currentBones, 0, Globals.startingBones)
				finish_story_event()
				return
			_:
				print("UNKNOWN CHOICE!!!")
				finish_story_event()
				return
		
func finish_story_event() -> void:
	visible = false
	Globals.currentDay += 1
	emit_signal("finished_story_event")

func has_reward(choiceData: StoryChoice) -> bool:
	if choiceData.rewards == null or choiceData.rewards.is_empty():
		return false
	return true
