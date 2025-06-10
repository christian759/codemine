extends Control

func _on_classic_pressed() -> void:
	get_tree().change_scene_to_file("res://board/board.tscn")

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://board/timeBoard.tscn") 

func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://navScreen/customBoard.tscn")
