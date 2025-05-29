extends Button

var x := 0
var y := 0
var grid_manager: Node =  null

func _ready():
	connect("pressed", _on_tile_pressed)

func _on_tile_pressed():
	if grid_manager:
		grid_manager.reveal_tile(x, y)
