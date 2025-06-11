extends Node

@onready var option1 = $ColorRect/VSplitContainer/HSplitContainer/OptionButton
@onready var option2  = $ColorRect/VSplitContainer/HSplitContainer2/OptionButton

func _ready():
	for i in range(1, 15):
		option1.add_item(str(i))
		option2.add_item(str(i))
		
	# default selections
	option1.select(7)
	option2.select(9)
	
	
func _on_button_pressed() -> void:
	var gridsize = option1.get_item_text(option1.get_selected())
	var bombnumber = option2.get_item_text(option2.get_selected())
	Global.gridSize = gridsize
	Global.bombNumber = bombnumber
	get_tree().change_scene_to_file("res://board/customBoard.tscn")
