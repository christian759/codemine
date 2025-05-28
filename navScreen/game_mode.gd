extends Control

func _on_classic_pressed() -> void:
	get_tree().change_scene_to_file("res://board/board.tscn")
