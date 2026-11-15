extends Camera2D

@export var target: Node2D
@export var follow_speed: float = 4.0


func _ready() -> void:
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	if target:
		global_position = target.global_position
	reset_smoothing()


func _physics_process(delta: float) -> void:
	if not target:
		return
		
	var weight := 1.0 - exp(-follow_speed * delta)
	global_position = global_position.lerp(target.global_position, weight)
