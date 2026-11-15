extends CanvasLayer
## Global UI manager, available everywhere as `UI` (autoload).
##
##   UI.open("pause")          push a screen on top
##   UI.close()                close the top screen (or UI.close(screen))
##   UI.change_scene(path)     fade out, swap scene, fade in
##   UI.restart_scene()        reload the current level
##   UI.hud                    the in-game HUD (null in menus)
##
## Esc opens the pause menu in-game, or closes the top screen.
## Scenes in the "menu" group (like the main menu) don't get a HUD or pause menu.

const MAIN_MENU := "res://ui/screens/main_menu.tscn"

## Overlay screens that can be opened by name.
const SCREENS := {
	"pause": preload("res://ui/screens/pause_menu.tscn"),
	"level_complete": preload("res://ui/screens/level_complete.tscn"),
}
const HUD_SCENE := preload("res://ui/screens/hud.tscn")

const SCENE_FADE_TIME := 0.25

signal screen_opened(screen_name: String)
signal screen_closed(screen_name: String)

var hud: UIScreen

var _stack: Array[UIScreen] = []
var _changing_scene := false

@onready var _screens: Control = $Screens
@onready var _fade: ColorRect = $Fade


func _ready() -> void:
	get_tree().scene_changed.connect(_refresh_hud)
	_refresh_hud.call_deferred()


func _unhandled_input(event: InputEvent) -> void:
	if _changing_scene or not event.is_action_pressed("ui_cancel"):
		return
	var screen := top()
	if screen:
		if screen.closable:
			close(screen)
		get_viewport().set_input_as_handled()
	elif is_in_game():
		open("pause")
		get_viewport().set_input_as_handled()


# --- Screens ---------------------------------------------------------------

func open(screen_name: String) -> UIScreen:
	assert(SCREENS.has(screen_name), "Unknown UI screen: %s" % screen_name)
	var screen: UIScreen = SCREENS[screen_name].instantiate()
	screen.screen_name = screen_name
	_screens.add_child(screen)
	_stack.push_back(screen)
	_update_pause()
	screen.open()
	screen_opened.emit(screen_name)
	return screen


func close(screen: UIScreen = null) -> void:
	if screen == null:
		screen = top()
	if screen == null or not _stack.has(screen):
		return
	_stack.erase(screen)
	screen.close()
	_update_pause()
	if top():
		top().grab_default_focus()
	screen_closed.emit(screen.screen_name)


func close_all() -> void:
	while top():
		close(top())


func top() -> UIScreen:
	return _stack.back() if not _stack.is_empty() else null


func is_open(screen_name: String) -> bool:
	return _stack.any(func(s: UIScreen) -> bool: return s.screen_name == screen_name)


func is_in_game() -> bool:
	var scene := get_tree().current_scene
	return scene != null and not scene.is_in_group("menu")


# --- Scenes ----------------------------------------------------------------

func change_scene(path: String) -> void:
	if _changing_scene:
		return
	_changing_scene = true
	close_all()
	await _fade_to(1.0)
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
	await get_tree().scene_changed
	await _fade_to(0.0)
	_changing_scene = false


func restart_scene() -> void:
	change_scene(get_tree().current_scene.scene_file_path)


func quit() -> void:
	get_tree().quit()


# --- Internals -------------------------------------------------------------

func _update_pause() -> void:
	get_tree().paused = _stack.any(func(s: UIScreen) -> bool: return s.pauses_game)


func _refresh_hud() -> void:
	if is_in_game() and hud == null:
		hud = HUD_SCENE.instantiate()
		_screens.add_child(hud)
		_screens.move_child(hud, 0) # keep it below menus
		hud.open()
	elif not is_in_game() and hud != null:
		hud.queue_free()
		hud = null


func _fade_to(alpha: float) -> void:
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP # block clicks mid-fade
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", alpha, SCENE_FADE_TIME)
	await tween.finished
	if alpha == 0.0:
		_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
