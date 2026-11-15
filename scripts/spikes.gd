@tool
class_name Spikes
extends Node2D
## A strip of spikes. Touching them kills the player.
## The origin is the bottom center, so place it on top of a platform. Set
## Width to make the strip longer; the drawing repeats to fill it.

const TEXTURE := preload("res://sprites/spikes.png")
## The part of spikes.png that has the drawing (skips the empty space above it).
const REGION := Rect2(0, 88, 300, 92)

## Length of the strip in pixels. Each spike is about 35px wide. A full running
## jump clears about 150px of spikes.
@export var width: float = 105.0:
	set(value):
		width = maxf(value, 10.0)
		queue_redraw()
## How big the spike drawing is (0.47 = about 40px tall).
@export var art_scale: float = 0.47:
	set(value):
		art_scale = maxf(value, 0.05)
		queue_redraw()
## How much of the spike height hurts, from the bottom. Lower is more forgiving
## at the tips.
@export_range(0.2, 1.0) var hitbox_height: float = 0.65


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	# Build the hitbox here so it always matches Width.
	var hitbox := Area2D.new()
	hitbox.collision_layer = 0
	hitbox.collision_mask = 2 # player
	hitbox.monitorable = false
	var shape := RectangleShape2D.new()
	var h := REGION.size.y * art_scale * hitbox_height
	shape.size = Vector2(maxf(width - 8.0, 4.0), h)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.position = Vector2(0, -h / 2.0)
	hitbox.add_child(collision)
	add_child(hitbox)
	hitbox.body_entered.connect(_on_body_entered)


func _draw() -> void:
	var tile := REGION.size * art_scale
	var x := -width / 2.0
	while x < width / 2.0 - 0.01:
		var w := minf(tile.x, width / 2.0 - x)
		var src := Rect2(REGION.position, Vector2(w / art_scale, REGION.size.y))
		draw_texture_rect_region(TEXTURE, Rect2(Vector2(x, -tile.y), Vector2(w, tile.y)), src)
		x += tile.x


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.die()
