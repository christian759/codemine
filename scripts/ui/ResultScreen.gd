extends Control

@onready var title_label: Label = $Panel/TitleLabel
@onready var time_label: Label = $Panel/VBox/TimeLabel
@onready var best_time_label: Label = $Panel/VBox/BestTimeLabel
@onready var replay_button: Button = $Panel/HBox/ReplayButton
@onready var menu_button: Button = $Panel/HBox/MenuButton
@onready var panel: Panel = $Panel

func _ready() -> void:
	hide()
	replay_button.pressed.connect(_on_replay_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func show_result(is_win: bool, time: int, mode: Constants.GameMode) -> void:
	show()
	panel.modulate.a = 0
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	
	if is_win:
		title_label.text = "YOU WIN!"
		title_label.add_theme_color_override("font_color", Color(0, 1.0, 1.0, 1.5)) # Neon Cyan
		
		var best = Globals.best_times[mode]
		if best == 0 or time < best:
			Globals.best_times[mode] = time
			best_time_label.text = "New Best: " + str(time) + "s"
			best_time_label.add_theme_color_override("font_color", Color("#f1c40f"))
		else:
			best_time_label.text = "Best: " + str(best) + "s"
			best_time_label.add_theme_color_override("font_color", Color(0.8, 0.8, 1.0, 1.5))
	else:
		title_label.text = "GAME OVER"
		title_label.add_theme_color_override("font_color", Color(1.0, 0, 1.0, 1.5)) # Neon Pink/Purple
		best_time_label.text = ""
		
	time_label.text = "Time: " + str(time) + "s"

func _on_replay_pressed() -> void:
	# Simplest way to restart is reload the scene, but better is to reset state.
	# We will reload the scene for a clean slate.
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")
