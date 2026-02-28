extends Control

@onready var classic_btn = %ClassicButton
@onready var timed_btn = %TimedButton
@onready var survival_btn = %SurvivalButton
@onready var lv_btn = %LimitedVisionButton

func _ready() -> void:
	classic_btn.pressed.connect(func(): _start_game(Constants.GameMode.CLASSIC))
	timed_btn.pressed.connect(func(): _start_game(Constants.GameMode.TIMED))
	survival_btn.pressed.connect(func(): _start_game(Constants.GameMode.SURVIVAL))
	lv_btn.pressed.connect(func(): _start_game(Constants.GameMode.LIMITED_VISION))

func _start_game(mode: Constants.GameMode) -> void:
	# Set active mode in Globals or pass it to GameManager
	# For simplicity, we just change the scene and let it pull from Globals or default
	# In this architecture, GameManager handles initialization. We will use a global approach or instantiate Game scene with params.
	var game_scene = preload("res://scenes/game/Game.tscn").instantiate()
	var root = get_tree().root
	# Remove current scene, add game scene
	var active = get_tree().current_scene
	root.remove_child(active)
	active.queue_free()
	
	root.add_child(game_scene)
	get_tree().current_scene = game_scene
	
	# The game scene has a GameManager as its first child or we can just find it.
	var game_manager = game_scene.get_node("GameManager")
	if game_manager:
		# Could pass config here, e.g., grid size
		if mode == Constants.GameMode.CLASSIC:
			game_manager.start_game(mode, 9, 9, 10)
		elif mode == Constants.GameMode.TIMED:
			game_manager.start_game(mode, 12, 12, 20)
		elif mode == Constants.GameMode.SURVIVAL:
			game_manager.start_game(mode, 16, 16, 40)
		elif mode == Constants.GameMode.LIMITED_VISION:
			game_manager.start_game(mode, 12, 12, 20)
