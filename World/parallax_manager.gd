extends Node2D

@export var background: Parallax2D
@export var foliage: Parallax2D
@export var focus: Parallax2D
@export var foreground: Parallax2D

@export var backgroundScrollScale: float = 1
@export var foliageScrollScale: float = 0.2
@export var focusScrollScale: float = 0.3
@export var foregroundScrollScale: float = 1

@export var parallaxSpeed: float = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	background.scroll_offset.x -= parallaxSpeed * backgroundScrollScale * 200 * delta
	foliage.scroll_offset.x -= parallaxSpeed * foliageScrollScale * 200 * delta
	focus.scroll_offset.x -= parallaxSpeed * focusScrollScale * 200 * delta
	foreground.scroll_offset.x -= parallaxSpeed * foregroundScrollScale * 200 * delta
	
