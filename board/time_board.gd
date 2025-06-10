extends "res://board/board.gd" # or whatever path your base script is

@onready var game_timer: Timer = $ColorRect/Timer
@onready var time_label: Label = $ColorRect/Label

var time_remaining := 60 # seconds

func _ready():
	super._ready()
	game_timer.wait_time = 1.0
	game_timer.one_shot = false
	game_timer.start()
	game_timer.timeout.connect(_on_game_timer_timeout)

func _on_game_timer_timeout():
	time_remaining -= 1
	time_label.text = "⏱️ Time Left: %ds" % time_remaining

	if time_remaining <= 0:
		_game_over_time()
		
func _on_restart_pressed():
	super._on_restart_pressed()
	time_remaining = 60
	time_label.text = "⏱️ Time Left: %ds" % time_remaining
	if game_timer.is_stopped():
		game_timer.start()

	game_over_popup.hide()
	_generate_board_data()
	_on_viewport_size_changed()

func _on_bomb_pressed():
	super._on_bomb_pressed()
	game_timer.stop()
	_reveal_all_tiles()
	_disable_all_tiles()
	_show_game_over_popup()
	return
	

func _game_over_time(): 
	game_timer.stop()
	_disable_all_tiles()
	_show_game_over_popup()
	game_over_popup.get_node("VBoxContainer/Label").text = "⏱️ Time's up!"
