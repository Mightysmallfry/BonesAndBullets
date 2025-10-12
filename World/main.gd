extends Node2D

# Both timers must be started again if we want to have them run once more
@onready var DestinationTimer: Timer = get_node("StoryProgressionTimer")
@onready var StoryEventTimer: Timer = get_node("StoryEventTimer")

@onready var StoryEventDisplay: Control = get_node("%StoryEventDisplay")


const STORY_EVENT_DIR: String = "res://StoryEvents/EventCache"
var _CachedEventFiles: Array[String] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.set_max_time(DestinationTimer, Globals.DestinationTime)
	Globals.set_max_time(StoryEventTimer, Globals.TimeBetweenStoryEvents)
	
	DestinationTimer.wait_time = Globals.get_max_time(DestinationTimer)
	StoryEventTimer.wait_time = Globals.get_max_time(StoryEventTimer)
	
	_CachedEventFiles = load_story_events(STORY_EVENT_DIR)

	if (Globals.has_timer(DestinationTimer)):
		DestinationTimer.start()
	if (Globals.has_timer(StoryEventTimer)):
		StoryEventTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_story_events(dirPath: String) -> Array[String]:
	var dir: DirAccess = DirAccess.open(dirPath)
	var files: Array[String] = []
	
	if dir == null:
		push_error("Could not find story event cache directory: %s", %dirPath)
		return files
	
	dir.list_dir_begin()
	var fileName: String = dir.get_next()
	
	while fileName != "":
		if not dir.current_is_dir() and fileName.ends_with(".tres"):
			files.append(dirPath + "/" + fileName)
		fileName = dir.get_next()
	
	dir.list_dir_end()
	return files

func get_random_story_event_data() -> StoryEventData:
	if _CachedEventFiles.is_empty():
		push_error("No events resources found in: %s", STORY_EVENT_DIR)
		return null
		
	var randomIndex: int = randi() % _CachedEventFiles.size()
	var storyEventPath: String = _CachedEventFiles[randomIndex]
	
	var storyDataAsResource: Resource = load(storyEventPath)
	if storyDataAsResource == null or not storyDataAsResource is StoryEventData:
		push_error("Failed to load valid StoryEventData at: %s", storyEventPath)
		return null
	
	return storyDataAsResource as StoryEventData

func _on_story_event_timer_timeout() -> void:
	DestinationTimer.set_paused(true)
	
	var storyEventData: StoryEventData = get_random_story_event_data()
	if (storyEventData):
		print("Loaded StoryEvent: %s", storyEventData.Title)
	
	StoryEventDisplay.load_story_event_data(storyEventData)
	StoryEventDisplay.visible = true
