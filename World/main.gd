extends Node2D

# Both timers must be started again if we want to have them run once more
@onready var destinationTimer: Timer = get_node("%StoryProgressionTimer")
@onready var storyEventTimer: Timer = get_node("%StoryEventTimer")
@onready var storyEventDisplay: Control = get_node("%StoryEventDisplay")

const STORY_EVENT_DIR: String = "res://StoryEvents/EventCache"
var _cachedEventFiles: Array[String] = []



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	storyEventDisplay.connect("finished_story_event", Callable(self, "_on_finished_story_event"))
	
	Globals.set_max_time(destinationTimer, Globals.destinationTime)
	Globals.set_max_time(storyEventTimer, Globals.timeBetweenStoryEvents)
	
	destinationTimer.wait_time = Globals.get_max_time(destinationTimer)
	storyEventTimer.wait_time = Globals.get_max_time(storyEventTimer)
	
	_cachedEventFiles = load_story_events(STORY_EVENT_DIR)

	if (Globals.has_timer(destinationTimer)):
		destinationTimer.start()
	if (Globals.has_timer(storyEventTimer)):
		storyEventTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func load_story_events(dirPath: String) -> Array[String]:
	var dir: DirAccess = DirAccess.open(dirPath)
	var files: Array[String] = []
	
	if dir == null:
		push_error("Could not find story event cache directory: " + dirPath)
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
	if _cachedEventFiles.is_empty():
		push_error("No events resources found in: %s", STORY_EVENT_DIR)
		return null
		
	var randomIndex: int = randi() % _cachedEventFiles.size()
	var storyEventPath: String = _cachedEventFiles[randomIndex]
	
	var storyDataAsResource: Resource = load(storyEventPath)
	if storyDataAsResource == null or not storyDataAsResource is StoryEventData:
		push_error("Failed to load valid StoryEventData at: " + storyEventPath)
		return null
	
	return storyDataAsResource as StoryEventData

func _on_story_event_timer_timeout() -> void:
	destinationTimer.set_paused(true)
	
	var storyEventData: StoryEventData = get_random_story_event_data()
	if (storyEventData):
		print("Loaded StoryEvent: " + storyEventData.title)
	
	storyEventDisplay.load_story_event_data(storyEventData)
	storyEventDisplay.visible = true
	
func _on_finished_story_event() -> void:
	# Continue Destination, restart eventTimer
	# If we want slight variations in time, this is where we would implement it.
	# then we also have to update the bars
	destinationTimer.set_paused(false)
	storyEventTimer.start()
	
	print("Game has resumed")


func _on_story_progression_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Menus/end_menu.tscn")
