extends Control

@onready var flags_label: Label = $FlagsLabel
@onready var time_label: Label = $TimeLabel

var game_manager: GameManager

func _ready() -> void:
	game_manager = get_tree().root.get_node("Game/GameManager")
	if game_manager:
		game_manager.flags_changed.connect(_on_flags_changed)
		game_manager.time_changed.connect(_on_time_changed)
		game_manager.game_won.connect(_on_game_over.bind(true))
		game_manager.game_lost.connect(_on_game_over.bind(false))

func _on_flags_changed(count: int) -> void:
	flags_label.text = "🚩 " + str(count)

func _on_time_changed(time: int) -> void:
	# Format as 000
	time_label.text = "⏱ " + "%03d" % time

func _on_game_over(is_win: bool) -> void:
	var result_scene = preload("res://scenes/ui/ResultScreen.tscn").instantiate()
	get_parent().add_child(result_scene)
	result_scene.show_result(is_win, game_manager.time_elapsed, game_manager.active_mode)
