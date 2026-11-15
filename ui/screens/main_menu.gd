extends UIScreen
## Title screen. This is a normal scene (the game's main scene), in the "menu" group.

func _ready() -> void:
	open()


func _on_play_pressed() -> void:
	Game.start_game()


func _on_quit_pressed() -> void:
	UI.quit()
