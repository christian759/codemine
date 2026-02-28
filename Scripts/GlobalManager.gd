extends Node

signal state_changed(new_state)
signal mode_changed(new_mode)
signal theme_changed(theme_id)

var current_state : Enums.GameState = Enums.GameState.IDLE :
	set(value):
		current_state = value
		state_changed.emit(current_state)

var current_mode : Enums.GameMode = Enums.GameMode.CLASSIC :
	set(value):
		current_mode = value
		mode_changed.emit(current_mode)

# Settings
var sound_enabled : bool = true
var vibration_enabled : bool = true
var color_theme : int = 0 :
	set(value):
		color_theme = value
		theme_changed.emit(color_theme)

# Survival / Persistent stats
var survival_round : int = 1
var best_time_classic : float = 9999.0
var score : int = 0

func reset_session_stats():
	survival_round = 1
	score = 0
