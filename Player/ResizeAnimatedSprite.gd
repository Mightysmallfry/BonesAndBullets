extends AnimatedSprite2D


func _ready() -> void:
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_resized"))
	update_scale()

	play("running")

		
		
func update_scale() -> void:
	_on_viewport_resized()

# Todo: Fix the scaling on the player.
func _on_viewport_resized() ->void:
	scale.x = Globals.scaleFactor 
	scale.y = Globals.scaleFactor
