extends UIScreen
## Shown after the last level. A normal scene in the "menu" group (no HUD/pause).

@onready var _stats: Label = %Stats


func _ready() -> void:
	_stats.text = "Total time  %s\nTotal deaths  %d" % [Game.format_time(Game.total_time), Game.total_deaths]
	open()


func _on_play_again_pressed() -> void:
	Game.start_game()


func _on_main_menu_pressed() -> void:
	UI.change_scene(UI.MAIN_MENU)
