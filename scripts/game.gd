extends Node
## Game flow, available everywhere as `Game` (autoload).
##
##   Game.start_game()       reset stats and go to the first level
##   Game.complete_level()   called by the goal flag; shows "Level Complete"
##   Game.next_level()       go to the next level, or the ending after the last one
##   Game.player_died()      called on falling off or getting hit; counts it and restarts
##
## To add a level: make the scene, put a Goal in it, and add it to LEVELS below.

## Levels in play order. "name" is shown in the HUD and the level banner.
const LEVELS: Array[Dictionary] = [
	{"path": "res://level_1.tscn", "name": "Level 1"},
	{"path": "res://level_2.tscn", "name": "Level 2"},
	{"path": "res://level_3.tscn", "name": "Level 3"},
]
const ENDING := "res://ui/screens/ending.tscn"

signal level_started(index: int)
signal level_completed(index: int)

## Time and deaths for the current level. Restarting the same level keeps them;
## they reset when a different level starts.
var level_time := 0.0
var level_deaths := 0
## Totals for the whole run since Game.start_game().
var total_time := 0.0
var total_deaths := 0

var _level_done := false
var _restarting := false
var _last_level := -1


func _ready() -> void:
	# Pausable, so the timers stop while the pause menu is open.
	process_mode = Node.PROCESS_MODE_PAUSABLE
	get_tree().scene_changed.connect(_on_scene_changed)
	_on_scene_changed.call_deferred()


func _process(delta: float) -> void:
	if current_level_index() >= 0 and not _level_done:
		level_time += delta
		total_time += delta


# --- Queries ---------------------------------------------------------------

func current_level_index() -> int:
	var scene := get_tree().current_scene
	if scene == null:
		return -1
	for i in LEVELS.size():
		if LEVELS[i].path == scene.scene_file_path:
			return i
	return -1


func current_level_name() -> String:
	var i := current_level_index()
	if i >= 0:
		return LEVELS[i].name
	var scene := get_tree().current_scene
	return scene.name.capitalize() if scene else ""


func is_last_level() -> bool:
	return current_level_index() == LEVELS.size() - 1


func is_level_done() -> bool:
	return _level_done


static func format_time(seconds: float) -> String:
	var mins := int(seconds) / 60
	return "%d:%04.1f" % [mins, seconds - mins * 60]


# --- Flow ------------------------------------------------------------------

func start_game() -> void:
	total_time = 0.0
	total_deaths = 0
	_last_level = -1
	UI.change_scene(LEVELS[0].path)


func complete_level() -> void:
	if _level_done:
		return
	_level_done = true
	level_completed.emit(current_level_index())
	UI.open("level_complete")


func next_level() -> void:
	var i := current_level_index()
	if i >= 0 and i + 1 < LEVELS.size():
		UI.change_scene(LEVELS[i + 1].path)
	else:
		UI.change_scene(ENDING)


## Play the current level again from scratch (fresh time and deaths).
func replay_level() -> void:
	_last_level = -1
	UI.restart_scene()


func player_died() -> void:
	if _restarting or _level_done:
		return
	_restarting = true
	level_deaths += 1
	total_deaths += 1
	UI.restart_scene()


# --- Internals -------------------------------------------------------------

func _on_scene_changed() -> void:
	_level_done = false
	_restarting = false
	var i := current_level_index()
	if i >= 0 and i != _last_level:
		level_time = 0.0
		level_deaths = 0
		_last_level = i
		level_started.emit(i)
