extends Control

@export var endGameButton: Button

@export var statsBody: RichTextLabel

@export var endingLabel: Label
@export var endingBody: RichTextLabel

@export var perfectEnding: int = Globals.startingBones
@export var goodEnding: int = 103
@export var terribleEnding: int = 0

const _deathStream:AudioStreamMP3 = preload("res://Assets/Music/[Death Theme]-Embraced by the Frost.mp3")
const _terribleStream:AudioStreamMP3 = preload("res://Assets/Music/[Terrible Ending]-The Instinct to Survive.mp3")
const _badStream:AudioStreamMP3 = preload("res://Assets/Music/[Bad Ending]-The difficult burden.mp3")
const _goodStream:AudioStreamMP3 = preload("res://Assets/Music/[Good Ending]-Sacrifices to be made.mp3")
const _bestStream:AudioStreamMP3 = preload("res://Assets/Music/[Best Ending]-I Will Never Give Up These Bones.mp3")

const BUTTON_HINT : String = "[Return to Main Menu]"
enum Ending {PERFECT, GOOD, BAD, TERRIBLE, DEAD}
var endingType : Ending
var stats : String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	if endGameButton == null:
		push_error("endGameButton Missing")
	if statsBody == null:
		push_error("statsBody Missing")
	if endingLabel == null:
		push_error("endingLabel Missing")
	if endingBody == null:
		push_error("endingBody Missing")
	
	get_ending(Globals.currentBones)
	print_ending(Globals.currentBones)
	print_stats()
	print_button()
	
func get_ending(boneCount : int) -> Ending:
	if Globals.playerHealth < 1:
		$AudioStreamPlayer2D.stream = _deathStream
		endingType = Ending.DEAD
	elif boneCount == perfectEnding:
		$AudioStreamPlayer2D.stream = _bestStream
		endingType = Ending.PERFECT
	elif boneCount < perfectEnding && boneCount >= goodEnding:
		$AudioStreamPlayer2D.stream = _goodStream
		endingType = Ending.GOOD
	elif boneCount < goodEnding: # bad ending else
		$AudioStreamPlayer2D.stream = _badStream
		endingType = Ending.BAD
	elif boneCount == terribleEnding:
		$AudioStreamPlayer2D.stream = _terribleStream
		endingType = Ending.TERRIBLE
	
	$AudioStreamPlayer2D.play()
	print("ending: " + str(endingType))
	return endingType
	
func print_button() -> void:
	var buttonDesc : String = ""
	
	match endingType:
		Ending.PERFECT:
			buttonDesc = EndingData.AFTERWORD_PERFECT
		Ending.GOOD:
			buttonDesc = EndingData.AFTERWORD_GOOD
		Ending.BAD:
			buttonDesc = EndingData.AFTERWORD_BAD
		Ending.TERRIBLE:
			buttonDesc = EndingData.AFTERWORD_TERRIBLE
		Ending.DEAD:
			buttonDesc = EndingData.AFTERWORD_DEAD
	
	endGameButton.text =  buttonDesc.format({"PERISHED_ONE" : Globals.deceasedName})+ "\n" + BUTTON_HINT 
	
func print_ending(boneCount : int) -> void:
	var endingHeader: String = ""
	var endingToWrite: String = ""
	
	match endingType:
		Ending.PERFECT:
			endingHeader = EndingData.PERFECT_ENDING_HEADER
			endingToWrite = EndingData.PERFECT_ENDING_BODY
		Ending.TERRIBLE:
			endingHeader = EndingData.TERRIBLE_ENDING_HEADER
			endingToWrite = EndingData.TERRIBLE_ENDING_BODY
		Ending.GOOD:
			endingHeader = EndingData.GOOD_ENDING_HEADER
			endingToWrite = EndingData.GOOD_ENDING_BODY
		Ending.BAD:
			endingHeader = EndingData.BAD_ENDING_HEADER
			endingToWrite = EndingData.BAD_ENDING_BODY
		Ending.DEAD:
			endingHeader = EndingData.DEAD_ENDING_HEADER
			endingToWrite = EndingData.DEAD_ENDING_BODY
	
	endingToWrite = endingToWrite.format({"PERISHED_ONE" : Globals.deceasedName})
	endingBody.set_dialog(endingToWrite)
	endingLabel.text = endingHeader

func print_stats() -> void:
	
	stats += "========================>\n"
	stats += "- Bones remaining: " + str(Globals.currentBones) + " bones\n"
	stats += "- Finished the game with : " + str(Globals.playerHealth) + " hp remaining\n"
	stats += "- Days spent traveling: " + str(Globals.currentDay) + "\n"
	stats += "========================>\n"
	stats += "- Total number of used bullets: " + str(Globals.totalBulletsUsed) + " bullets\n"
	stats += "- Total number of bullets found: " + str(Globals.totalBulletsFound) + " bullets \n"
	stats += "- Total Health gained: " + str(Globals.totalHealthGained) + " hp\n"
	stats += "- Total Health Lost: " + str(Globals.totalHealthLost) + " hp\n"
	
	statsBody.set_dialog(stats)
