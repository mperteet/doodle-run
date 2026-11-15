extends UIScreen
## Always-on in-game overlay. Add health, score, etc. here and reach it with `UI.hud`.

const BANNER_HOLD := 1.2

@onready var level_label: Label = %LevelLabel
@onready var time_label: Label = %TimeLabel
@onready var banner: Label = %Banner


func _ready() -> void:
	banner.modulate.a = 0.0
	Game.level_started.connect(_on_level_started)


func _on_open() -> void:
	level_label.text = Game.current_level_name()


func _process(_delta: float) -> void:
	time_label.text = Game.format_time(Game.level_time)


## Big level name that fades in and out when a new level starts
## (not on restarts of the same level).
func _on_level_started(_index: int) -> void:
	level_label.text = Game.current_level_name()
	banner.text = Game.current_level_name()
	var tween := create_tween()
	tween.tween_property(banner, "modulate:a", 1.0, 0.3)
	tween.tween_interval(BANNER_HOLD)
	tween.tween_property(banner, "modulate:a", 0.0, 0.5)
