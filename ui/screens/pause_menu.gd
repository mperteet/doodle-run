extends UIScreen
## Opened with Esc during gameplay. Pauses the game while open.


func _on_resume_pressed() -> void:
	UI.close(self)


func _on_restart_pressed() -> void:
	UI.restart_scene()


func _on_main_menu_pressed() -> void:
	UI.change_scene(UI.MAIN_MENU)
