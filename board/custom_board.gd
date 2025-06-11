extends "res://board/board.gd"

func _ready():
	super._ready()
	WIDTH = int(Global.gridSize)
	HEIGHT = int(Global.gridSize)

	BOMB_COUNT = int(Global.bombNumber)

	restart_button.pressed.connect(_on_restart_pressed)
	back_button.pressed.connect(_on_back_pressed)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_generate_board_data()
	_on_viewport_size_changed()
