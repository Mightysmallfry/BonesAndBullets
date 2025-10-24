extends TextureProgressBar


@export var timer: Timer

var initialized: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if timer == null:
		push_error("TimedProgressBar lacks a timer!")
		return
	
	max_value = Globals.destinationTime
	if Globals.current_time > 0.0:
		value = Globals.current_time
	else:
		value = 0.0
	
	if Globals.has_timer(timer):
		max_value = Globals.get_max_time(timer)
	else:
		push_warning("Timer not registered yet, delaying max_value assignment")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not initialized:
		if Globals.has_timer(timer):
			max_value = Globals.get_max_time(timer)
			initialized = true
	else:
		if timer.time_left > 0:
				max_value = Globals.get_max_time(timer)
				value = clamp(max_value - timer.time_left, min_value, max_value)
		# print("time_left:", timer.time_left, "value:", value, "max_value:", max_value)
	
