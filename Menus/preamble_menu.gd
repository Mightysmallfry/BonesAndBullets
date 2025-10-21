extends Control

@export var dateSegment: RichTextLabel
@export var loreSegment: RichTextLabel

const SEGMENT_DELAY: float = 1.5

# Post Krill (lol)
var initialDate: String = "20XX"
var lore: String = "This land is eternal. 
Shadows of grey mourning and visions of red remains litter the landscape. 
Today I undertake a journey: Iron in hand, brass in pocket. 
In this journal, my story will lay to rest. 
In their honor, nothing is more important than this delivery. They were everything. 
Now, just bones to be delivered to an ‘ancestral home’. 
I never believed in that stuff. Still don’t. But I believed in them. 
That’s good enough for me. 
So whether it be raiders, frozen wastelands, or staggering constructs that get in my way, it doesn’t matter. 
These bones and brass are getting me to the end. Or I’ll die trying."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(SEGMENT_DELAY).timeout
	dateSegment.TYPEWRITER_SPEED = 0.25
	dateSegment.set_dialog(initialDate)
	await get_tree().create_timer(SEGMENT_DELAY).timeout
	dateSegment.TYPEWRITER_SPEED = 0.035
	loreSegment.set_dialog(lore)
