extends Node2D

@export_category("Player Variables")
@export var playerHealth: int = 100
@export var startingBones: int = 319
@export var bullets: int = 6

@export_category("Timing Variables")
# Measured in seconds ~5 minutes
@export var destinationTime: float = 300
# This could change as a range of 20-40 seconds
# When story event happens, pause the time until destination.
@export var timeBetweenStoryEvents: float = 10

var IsPaused: bool = false

## Boolean if player is using a controler or keyboard
var on_controller:bool = false

var timerMaxTimes: Dictionary = { }

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	
