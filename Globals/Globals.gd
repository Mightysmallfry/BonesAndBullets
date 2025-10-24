extends Node2D

@export_category("Player Variables")
@export var playerHealth: int = 100
@export var startingBones: int = 206
@export var currentBones: int = startingBones
@export var bullets: int = 6
@export var maxBullets: int = 12
@export var maxHealth: int = 100

var totalBulletsUsed: int = 0
var totalBulletsFound: int = 0
var totalHealthLost: int = 0
var totalHealthGained: int = 0

@export_category("Player Combat Skills")
@export_range(1,100,1) var combat_speed:int = 50
@export_range(1,100,1) var combat_aim:int = 50
@export_range(1,100,1) var combat_melee:int = 50

@export_category("Timing Variables")
# Measured in seconds ~5 minutes
@export var destinationTime: float = 300
# This could change as a range of 20-40 seconds
# When story event happens, pause the time until destination.
@export var timeBetweenStoryEvents: float = 15
@export var startingDay: int = 1
@export var currentDay: int

var deceasedName : String = "Randy"

var current_time:float = 0.0
var IsPaused: bool = false
## Boolean if player is using a controler or keyboard
var on_controller:bool = false

var timerMaxTimes: Dictionary = { }

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentDay = startingDay
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
	
