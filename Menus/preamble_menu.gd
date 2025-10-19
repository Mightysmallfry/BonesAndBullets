extends Control

@export var dateSegment: RichTextLabel
@export var loreSegment: RichTextLabel

const SEGMENT_DELAY: float = 1.5

# Post Krill
var initialDate: String = "542 PK"
var lore: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Cras sodales nulla felis, vitae tristique libero porttitor at.
Pellentesque habitant morbi tristique senectus et netus et malesuada 
fames ac turpis egestas. Interdum et malesuada fames ac ante ipsum primis 
in faucibus. Quisque vestibulum sollicitudin sem ac lobortis. Sed laoreet laoreet ligula sed maximus.
Aenean sed quam id risus dictum porta. Cras a sapien id dui aliquet pulvinar.

Nulla varius ac justo sed accumsan. Donec lectus odio, tincidunt in varius at,
posuere id magna. Ut sit amet semper lacus. Vestibulum ante ipsum primis in
faucibus orci luctus et ultrices posuere cubilia curae; Vivamus lacinia velit ac
varius iaculis. Sed congue nibh vel consequat consectetur. Maecenas pellentesqueut
velit sed hendrerit. Maecenas ut ullamcorper neque, non congue mauris."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(SEGMENT_DELAY).timeout
	dateSegment.TYPEWRITER_SPEED = 0.25
	dateSegment.set_dialog(initialDate)
	await get_tree().create_timer(SEGMENT_DELAY).timeout
	dateSegment.TYPEWRITER_SPEED = 0.035
	loreSegment.set_dialog(lore)
