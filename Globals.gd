extends Node


@export var PlayerHealth: int = 100
@export var StartingBones: int = 319
@export var Bullets: int = 6

# Measured in seconds ~5 minutes
@export var DestinationTime: float = 300
# This could change as a range of 20-40 seconds
# When story event happens, pause the time until destination.
@export var TimeBetweenStoryEvents: float = 30

var timer_max_times: Dictionary = { }


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_max_time(timer: Timer, max_time: float):
	timer_max_times[timer] = max_time
	
func has_timer(timer: Timer) -> bool:
	return timer in timer_max_times
	
func get_max_time(timer: Timer) -> float:
	if timer in timer_max_times:
		return timer_max_times[timer]
	return 0.0 
