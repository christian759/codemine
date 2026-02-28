extends Node
class_name GameManager

signal game_won()
signal game_lost()
signal flags_changed(current: int)
signal time_changed(time: int)
signal timer_stopped()

enum GameState { IDLE, PLAYING, GAME_OVER, WIN }

var current_state: GameState = GameState.IDLE
var active_mode: Constants.GameMode = Constants.GameMode.CLASSIC

var time_elapsed: int = 0
var timer: Timer

var mine_count: int = Constants.DEFAULT_MINE_COUNT
var flags_placed: int = 0
var tiles_revealed: int = 0
var total_safe_tiles: int = 0

var grid_manager: Node
var camera_controller: CameraController

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_on_timer_tick)
	add_child(timer)

	# Find GridManager in scene
	grid_manager = get_tree().get_first_node_in_group("GridManager")
	if grid_manager:
		grid_manager.tile_revealed.connect(_on_tile_revealed)
		grid_manager.mine_exploded.connect(_on_mine_exploded)
		grid_manager.flag_toggled.connect(_on_flag_toggled)

	camera_controller = get_tree().get_first_node_in_group("CameraController")

func start_game(mode: Constants.GameMode = active_mode, w: int = Constants.DEFAULT_BOARD_WIDTH, h: int = Constants.DEFAULT_BOARD_HEIGHT, mines: int = Constants.DEFAULT_MINE_COUNT) -> void:
	active_mode = mode
	current_state = GameState.IDLE
	time_elapsed = 0
	flags_placed = 0
	tiles_revealed = 0
	mine_count = mines
	total_safe_tiles = (w * h) - mine_count

	timer.stop()
	time_changed.emit(time_elapsed)
	flags_changed.emit(mine_count - flags_placed)

	if grid_manager:
		grid_manager.generate_grid(w, h, mines, mode)

func start_timer():
	if current_state == GameState.IDLE:
		current_state = GameState.PLAYING
		timer.start()

func _on_timer_tick():
	if current_state == GameState.PLAYING:
		time_elapsed += 1
		time_changed.emit(time_elapsed)

func _on_tile_revealed(is_mine: bool) -> void:
	if current_state == GameState.IDLE:
		start_timer()
		
	if is_mine:
		_trigger_loss()
		return

	tiles_revealed += 1
	_check_win_condition()

func _on_mine_exploded() -> void:
	_trigger_loss()

func _on_flag_toggled(is_placed: bool) -> void:
	if current_state != GameState.PLAYING and current_state != GameState.IDLE:
		return
	
	if is_placed:
		flags_placed += 1
	else:
		flags_placed -= 1
		
	flags_changed.emit(mine_count - flags_placed)

func _trigger_loss() -> void:
	if current_state == GameState.GAME_OVER:
		return
	current_state = GameState.GAME_OVER
	timer.stop()
	timer_stopped.emit()
	if grid_manager:
		grid_manager.reveal_all_mines()
	Globals.play_vibration(200)
	if camera_controller:
		camera_controller.add_trauma(0.8) # Big shake for explosion
	game_lost.emit()

func _check_win_condition() -> void:
	if current_state == GameState.GAME_OVER or current_state == GameState.WIN:
		return
		
	if tiles_revealed == total_safe_tiles:
		current_state = GameState.WIN
		timer.stop()
		timer_stopped.emit()
		if grid_manager:
			grid_manager.flag_all_mines()
		Globals.play_vibration(100) # Quick win vibration
		if camera_controller:
			camera_controller.add_trauma(0.4) # Small happy shake for win
		game_won.emit()

func is_playing() -> bool:
	return current_state == GameState.PLAYING or current_state == GameState.IDLE
