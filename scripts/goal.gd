extends Area2D
## End-of-level goal: a pencil-lead case that slowly floats up and down.
## Touching it finishes the level. The origin is at the bottom, so place it on
## top of a platform; the case hovers a little above that spot.

## How far it drifts up and down (pixels).
@export var bob_height: float = 12.0
## Seconds for one full up-and-down.
@export var bob_period: float = 2.6

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _base_y: float = _sprite.position.y
var _time := 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	_sprite.position.y = _base_y + sin(_time * TAU / bob_period) * bob_height


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Game.complete_level()
