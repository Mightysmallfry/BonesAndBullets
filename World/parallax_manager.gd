extends Node2D

@export var background: Parallax2D
@export var foliage: Parallax2D
@export var focus: Parallax2D
@export var foreground: Parallax2D

@export_category("Scroll Scale")
@export var backgroundScrollScale: float = 1
@export var foliageScrollScale: float = 0.2
@export var focusScrollScale: float = 0.3
@export var foregroundScrollScale: float = 1

@export_category("Scroll Speed")
@export var speedConst:float = 80
@export var parallaxSpeed: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	background.scroll_offset.x -= parallaxSpeed * backgroundScrollScale * speedConst * delta
	foliage.scroll_offset.x -= parallaxSpeed * foliageScrollScale * speedConst * delta
	focus.scroll_offset.x -= parallaxSpeed * focusScrollScale * speedConst * delta
	foreground.scroll_offset.x -= parallaxSpeed * foregroundScrollScale * speedConst * delta
	
