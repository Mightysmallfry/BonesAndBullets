extends Node2D

@export var playerHealth: int = 100
@export var startingBones: int = 319
@export var bullets: int = 6

# Measured in seconds ~5 minutes
@export var destinationTime: float = 300
# This could change as a range of 20-40 seconds
# When story event happens, pause the time until destination.
@export var timeBetweenStoryEvents: float = 10

@export var baseScreenSize: Vector2 = Vector2(1152, 648) # baseline to scale from
@export var baseAmount: int = 1000  # particle amount at base resolution
@export var baseScale: float = 1.0 # particle scale at base resolution

var IsPaused: bool = false

## Boolean if player is using a controler or keyboard
var on_controller:bool = false

var timerMaxTimes: Dictionary = { }
var scaleFactor: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_resized"))
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_max_time(timer: Timer, max_time: float):
	timerMaxTimes[timer] = max_time
	
func has_timer(timer: Timer) -> bool:
	return timer in timerMaxTimes
	
func get_max_time(timer: Timer) -> float:
	if timer in timerMaxTimes:
		return timerMaxTimes[timer]
	return 0.0 
	
func _on_viewport_resized() ->void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var screenHeight: float = viewport_size.y
	var screenWidth: float = viewport_size.x
	
	scaleFactor = ((screenWidth * screenHeight) / (baseScreenSize.x * baseScreenSize.y))
