class_name Player
extends CharacterBody2D

@export_category("Movement Variables")
@export var walk_velocity: float = 240.0
@export var jump_velocity: float = -650.0
@export var gravity: float = 1500.0
@export var fall_gravity_multiplier: float = 1.3
## Falling below this height (world Y, down is positive) restarts the level.
@export var fall_limit_y: float = 800.0

@export_category("Sprites")
@export var idle_texture: Texture2D = preload("res://sprites/idle.png")
## Should face right; it's mirrored automatically when walking left.
@export var walk_texture: Texture2D = preload("res://sprites/walk.png")
## Shown while in the air (jumping or falling).
@export var jump_texture: Texture2D = preload("res://sprites/jump.png")
## On-screen size of each image. The drawings are at different sizes, so these
## make the character match (based on body height / head width of each drawing).
@export var idle_scale: float = 0.327
@export var walk_scale: float = 0.207
@export var jump_scale: float = 0.196

@onready var sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D
var _anchor_cache: Dictionary = {}
var _dead := false

func _physics_process(delta: float) -> void:
	# 1. Apply gravity
	if not is_on_floor():
		var current_gravity = gravity * fall_gravity_multiplier if velocity.y > 0 else gravity
		velocity.y += current_gravity * delta

	# 2. Handle Jump & Variable Jump Cancellation
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.3 # Cuts upward momentum for variable jump height

	# 3. Handle Horizontal Input (Snappy start/stop)
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * walk_velocity
	else:
		velocity.x = move_toward(velocity.x, 0, walk_velocity)

	move_and_slide()
	_update_sprite(direction)

	# 4. Fell off the world
	if global_position.y > fall_limit_y:
		die()


## Called when falling off the world or touching an enemy. Freezes the player
## and restarts the level.
func die() -> void:
	if _dead:
		return
	_dead = true
	set_physics_process(false)
	sprite.modulate = Color(1, 0.45, 0.45)
	Game.player_died()


func _update_sprite(direction: float) -> void:
	var texture := idle_texture
	var size := idle_scale
	var flip := false
	if not is_on_floor():
		texture = jump_texture
		size = jump_scale
		flip = direction < 0
	elif direction != 0:
		texture = walk_texture
		size = walk_scale
		flip = direction < 0

	sprite.texture = texture
	sprite.flip_h = flip
	sprite.scale = Vector2(size, size)

	# The drawings aren't centered in their images and have different amounts of
	# empty space, so line each one up: head centered over the collision box,
	# feet exactly on its bottom edge.
	var anchor := _anchor(texture) - texture.get_size() / 2.0
	var x_offset := -anchor.x
	if flip:
		x_offset = -x_offset
	sprite.offset = Vector2(
		(_collision.position.x - sprite.position.x) / size + x_offset,
		(_collision_bottom() - sprite.position.y) / size - anchor.y
	)


## Bottom edge of the collision box, in the player's local space.
func _collision_bottom() -> float:
	var rect := _collision.shape.get_rect()
	return _collision.position.y + rect.end.y * _collision.scale.y


## Where the character is in the image: x = center of the head, y = bottom of
## the feet. Measured once per image from its non-transparent pixels.
func _anchor(texture: Texture2D) -> Vector2:
	if _anchor_cache.has(texture):
		return _anchor_cache[texture]
	var img := texture.get_image()
	if img.is_compressed():
		img.decompress()
	var w := img.get_width()
	var h := img.get_height()
	var top := -1
	var bottom := -1
	for y in h:
		for x in w:
			if img.get_pixel(x, y).a > 0.5:
				if top < 0:
					top = y
				bottom = y
				break
	if top < 0:
		return Vector2(w / 2.0, h)
	# Head = the top 20% of the drawing.
	var head_bottom := top + int((bottom - top) * 0.2)
	var left := w
	var right := -1
	for y in range(top, head_bottom + 1):
		for x in w:
			if img.get_pixel(x, y).a > 0.5:
				left = mini(left, x)
				right = maxi(right, x)
	var anchor := Vector2((left + right + 1) / 2.0, bottom + 1.0)
	_anchor_cache[texture] = anchor
	return anchor
