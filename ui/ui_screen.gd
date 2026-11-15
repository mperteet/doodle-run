class_name UIScreen
extends Control
## Base class for every menu/overlay. Extend this for new screens and register
## them in `ui_manager.gd` (SCREENS) so you can open them with `UI.open("name")`.

## Freeze the game while this screen is open.
@export var pauses_game: bool = false
## Let Esc (ui_cancel) close this screen.
@export var closable: bool = true
## Control that gets keyboard/gamepad focus when the screen opens.
@export var default_focus: Control

const FADE_TIME := 0.15

var screen_name: String = ""


## Called by the UI manager. Fades in and focuses `default_focus`.
func open() -> void:
	show()
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, FADE_TIME)
	grab_default_focus()
	_on_open()


## Called by the UI manager. Fades out, then frees the screen.
func close() -> void:
	_on_close()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	propagate_call("set_process_input", [false])
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
	tween.finished.connect(queue_free)


func grab_default_focus() -> void:
	_grab_focus_now.call_deferred()


func _grab_focus_now() -> void:
	if default_focus and default_focus.is_inside_tree() and default_focus.is_visible_in_tree():
		default_focus.grab_focus()


## Override in subclasses for setup when the screen appears.
func _on_open() -> void:
	pass


## Override in subclasses for cleanup when the screen goes away.
func _on_close() -> void:
	pass
