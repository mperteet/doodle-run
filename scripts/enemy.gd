class_name Enemy
extends CharacterBody2D
## Eraser enemy. Walks back and forth along whatever platform it's standing on,
## turning around at ledges (so it never falls off) and at walls. Touching it
## kills the player. The origin is at its bottom, so place it on top of a platform.

@export var speed: float = 80.0
@export var gravity: float = 1500.0
## Which way it starts walking.
@export_enum("Left:-1", "Right:1") var start_direction: int = 1
## Which way the eraser drawing faces. The sprite is mirrored to match the
## walking direction.
@export var art_faces_left: bool = true
## How far ahead of its center it checks for ground (about half its width).
@export var edge_lookahead: float = 50.0

var direction: int = 1

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _edge_ray: RayCast2D = $EdgeRay
@onready var _sprite_base_y: float = _sprite.position.y
var _time := 0.0


func _ready() -> void:
	direction = start_direction
	$Hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	_update_facing()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Look for ground just ahead; if there's none, turn around.
		_edge_ray.position.x = edge_lookahead * direction
		_edge_ray.force_raycast_update()
		if not _edge_ray.is_colliding():
			direction = -direction

	velocity.x = speed * direction
	move_and_slide()

	if is_on_wall():
		direction = 1 if get_wall_normal().x > 0 else -1

	_update_facing()

	# Little scrubbing wobble while it moves.
	_time += delta
	_sprite.rotation = sin(_time * 10.0) * 0.04
	_sprite.position.y = _sprite_base_y - absf(sin(_time * 10.0)) * 2.0


func _update_facing() -> void:
	_sprite.flip_h = (direction > 0) == art_faces_left


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
