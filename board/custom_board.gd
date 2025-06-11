extends "res://board/board.gd"

func _ready():
    WIDTH = int(Global.gridSize)
    HEIGHT = int(Global.gridSize)

    BOMB_COUNT = int(Global.bombNumber)

