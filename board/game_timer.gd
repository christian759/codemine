extends "res://board/board.gd" # or whatever path your base script is

@onready var game_timer: Timer = $GameTimer
@onready var time_label: Label = $TimeLabel

var time_remaining := 60 # seconds

func _ready():
	super._ready()
	game_timer.wait_time = 1.0
	game_timer.autostart = true
	game_timer.timeout.connect(_on_game_timer_timeout)

func _process(delta):
	time_label.text = "⏱️ Time Left: %ds" % time_remaining

func _on_game_timer_timeout():
	time_remaining -= 1
	if time_remaining <= 0:
		_game_over_time()

func _game_over_time():
	game_timer.stop()
	_disable_all_tiles()
	_show_game_over_popup()
	game_over_popup.get_node("VBoxContainer/Label").text = "⏱️ Time's up!"
