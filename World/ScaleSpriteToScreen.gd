extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#get_viewport().connect("size_changed", Callable(self, "_on_viewport_resized"))
	#update_scale()
	
	pass # Replace with function body.

func update_scale() -> void:
	_on_viewport_resized()
	
	
func _on_viewport_resized() ->void:
	scale.x = Globals.scaleFactor + 3.6
	scale.y = Globals.scaleFactor + 3.6

	global_position = get_viewport_rect().size * 0.5
	
