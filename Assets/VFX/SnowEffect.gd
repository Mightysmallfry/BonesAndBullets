extends GPUParticles2D

@onready var particleProcessMaterial: ParticleProcessMaterial = (
	process_material as ParticleProcessMaterial
)

@export var baseScreenSize: Vector2 = Vector2(1152, 648) # baseline to scale from
@export var baseAmount: int = 1000  # particle amount at base resolution
@export var baseScale: float = 1.0 # particle scale at base resolution

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if particleProcessMaterial == null:
		particleProcessMaterial = ParticleProcessMaterial.new()
		process_material = particleProcessMaterial
	
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_resized"))
	update_particle_settings()

func _on_viewport_resized() -> void:
	update_particle_settings()
	
	
func update_particle_settings() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var screenHeight: float = viewport_size.y
	var screenWidth: float = viewport_size.x
	var scaleFactor = Globals.scaleFactor

	particleProcessMaterial.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	particleProcessMaterial.emission_box_extents = Vector3(screenWidth * 0.5, screenHeight * 0.5, 0.0)

	global_position = viewport_size * 0.5
	
	var half_size: Vector2 = viewport_size * 0.5
	visibility_rect = Rect2(-half_size, viewport_size)
	
	particleProcessMaterial.scale_min = baseScale * sqrt(scaleFactor)
	particleProcessMaterial.scale_max = baseScale * sqrt(scaleFactor)
	
	amount = int(baseAmount * scaleFactor)
	amount = clamp(amount, 100, 5000)
	
