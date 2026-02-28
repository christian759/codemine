extends Node

var allow_vibration: bool = true
var allow_sound: bool = true
var color_theme: int = 0 # 0: Dark, 1: Light, 2: Colorful

# Keep track of best times/score
# In a full game this would be saved to user://
var best_times: Dictionary = {
	Constants.GameMode.CLASSIC: 0,
	Constants.GameMode.TIMED: 0,
	Constants.GameMode.SURVIVAL: 0
}

func play_vibration(duration_ms: int = 50):
	if allow_vibration:
		Input.vibrate_handheld(duration_ms)
