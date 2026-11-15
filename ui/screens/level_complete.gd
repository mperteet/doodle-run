extends UIScreen
## Shown when the player reaches a level's Goal. Pauses the game.

@onready var _title: Label = %Title
@onready var _stats: Label = %Stats
@onready var _next: Button = %Next


func _on_open() -> void:
	_title.text = "%s Complete!" % Game.current_level_name()
	_stats.text = "Time  %s\nDeaths  %d" % [Game.format_time(Game.level_time), Game.level_deaths]
	_next.text = "Finish" if Game.is_last_level() else "Next Level"


func _on_next_pressed() -> void:
	Game.next_level()


func _on_replay_pressed() -> void:
	Game.replay_level()


func _on_main_menu_pressed() -> void:
	UI.change_scene(UI.MAIN_MENU)
