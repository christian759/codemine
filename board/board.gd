extends Node

const WIDTH := 8
const HEIGHT := 8
const BOMB_COUNT := 10
const HORIZONTAL_TILE_MARGIN := 4
const VERTICAL_TILE_MARGIN := 4
const MAX_TILE_SIZE := 48

@onready var tile_scene = preload("res://board/TileButton.tscn")
@onready var bottom_scene = preload("res://board/bottom/BottomNode.tscn")

var tiles = []
var tile_nodes = []

@onready var bgColor: ColorRect = $ColorRect
@onready var game_over_popup: PopupPanel = $PopupPanel
@onready var restart_button: Button = $PopupPanel/VBoxContainer/HBoxContainer/RestartButton
@onready var back_button: Button = $PopupPanel/VBoxContainer/HBoxContainer/BackButton
@onready var board_content: Control = $ColorRect/CenterContainer/VBoxContainer/VBoxContainer2/boardContent
@onready var tile_layer: GridContainer = $ColorRect/CenterContainer/VBoxContainer/VBoxContainer2/boardContent/TileLayer

var pick_mode := true

var pick_button: Button
var flag_button: Button

func _ready():
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_generate_board_data()
	_on_viewport_size_changed()
	restart_button.pressed.connect(_on_restart_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_viewport_size_changed():
	clear_grid()
	generate_grid()

func get_bottom_bar_height():
	var viewport_size = get_viewport().size
	return max(viewport_size.y * 0.1, 48)

func get_dynamic_tile_size():
	var viewport_size = get_viewport().size
	var bottom_bar_height = get_bottom_bar_height()
	var available_height = viewport_size.y - bottom_bar_height - 16
	var tile_width = (viewport_size.x - (WIDTH - 1) * HORIZONTAL_TILE_MARGIN) / WIDTH
	var tile_height = (available_height - (HEIGHT - 1) * VERTICAL_TILE_MARGIN) / HEIGHT
	return min(tile_width, tile_height, MAX_TILE_SIZE)

func _generate_board_data():
	tiles.clear()
	for y in HEIGHT:
		var row = []
		for x in WIDTH:
			row.append(MineTileData.new())
		tiles.append(row)

	var placed := 0
	while placed < BOMB_COUNT:
		var rx = randi() % WIDTH
		var ry = randi() % HEIGHT
		if not tiles[ry][rx].is_bomb:
			tiles[ry][rx].is_bomb = true
			placed += 1

	for y in HEIGHT:
		for x in WIDTH:
			if tiles[y][x].is_bomb:
				continue
			var count = 0
			for ny in range(y - 1, y + 2):
				for nx in range(x - 1, x + 2):
					if is_valid(nx, ny) and tiles[ny][nx].is_bomb:
						count += 1
			tiles[y][x].neighbor_bombs = count

func clear_grid():
	for row in tile_nodes:
		for tile in row:
			if tile:
				tile.queue_free()
	tile_nodes.clear()
	if tile_layer:
		for child in tile_layer.get_children():
			child.queue_free()
		# tile_layer.clear() # Ensure tile_layer is cleared of all children

func generate_grid():
	tile_nodes.clear()
	var tile_size = get_dynamic_tile_size()
	for y in HEIGHT:
		var node_row = []
		for x in WIDTH:
			var tile = tile_scene.instantiate()
			tile.x = x
			tile.y = y
			tile.grid_manager = self
			tile.position = Vector2(
				x * (tile_size + HORIZONTAL_TILE_MARGIN),
				y * (tile_size + VERTICAL_TILE_MARGIN)
			)
			tile.custom_minimum_size = Vector2(tile_size, tile_size)

			var data = tiles[y][x]
			if data.is_revealed:
				if data.is_bomb:
					tile.text = "💣"
				elif data.neighbor_bombs > 0:
					tile.text = str(data.neighbor_bombs)
				else:
					tile.text = ""
				tile.disabled = true
			elif data.is_flagged:
				tile.text = "🚩"
			else:
				tile.text = ""

			node_row.append(tile)
			if tile_layer:
				tile_layer.add_child(tile)
		tile_nodes.append(node_row)

func _on_pick_button_pressed():
	pick_mode = true
	_update_bottom_bar_buttons()

func _on_flag_button_pressed():
	pick_mode = false
	_update_bottom_bar_buttons()

func _update_bottom_bar_buttons():
	if pick_button:
		pick_button.disabled = pick_mode
	if flag_button:
		flag_button.disabled = not pick_mode

func reveal_tile(x, y):
	if pick_mode:
		_reveal_tile_logic(x, y)
	else:
		_flag_tile_logic(x, y)

func _reveal_tile_logic(x, y):
	var data = tiles[y][x]
	var button = tile_nodes[y][x]
	if data.is_revealed or data.is_flagged:
		return
	data.is_revealed = true

	if data.is_bomb:
		button.text = "💣"
		button.disabled = true
		_reveal_all_tiles()
		_disable_all_tiles()
		_show_game_over_popup()
		return

	if data.neighbor_bombs > 0:
		button.text = str(data.neighbor_bombs)
	else:
		button.text = ""
		for ny in range(y - 1, y + 2):
			for nx in range(x - 1, x + 2):
				if is_valid(nx, ny) and not (nx == x and ny == y):
					_reveal_tile_logic(nx, ny)
	button.disabled = true
	_check_win_condition()

func _flag_tile_logic(x, y):
	var data = tiles[y][x]
	var button = tile_nodes[y][x]
	if data.is_revealed:
		return
	data.is_flagged = not data.is_flagged
	button.text = "🚩" if data.is_flagged else ""
	_check_win_condition()

func _check_win_condition():
	for y in HEIGHT:
		for x in WIDTH:
			var data = tiles[y][x]
			if not data.is_bomb and not data.is_revealed:
				return
	_show_win_popup()

func _show_win_popup():
	var label = game_over_popup.get_node("VBoxContainer/Label")
	if label:
		label.text = "You Win!"
	game_over_popup.popup_centered()

func _reveal_all_tiles():
	for row in tile_nodes:
		for tile in row:
			var data = tiles[tile.y][tile.x]
			if data.is_bomb:
				tile.text = "💣"
			elif data.neighbor_bombs > 0:
				tile.text = str(data.neighbor_bombs)
			else:
				tile.text = ""
			tile.disabled = true

func _disable_all_tiles():
	for row in tile_nodes:
		for tile in row:
			tile.disabled = true

func is_valid(x, y):
	return x >= 0 and x < WIDTH and y >= 0 and y < HEIGHT

func _show_game_over_popup():
	var label = game_over_popup.get_node("VBoxContainer/Label")
	if label:
		label.text = "Game Over"
	game_over_popup.popup_centered()

func _on_restart_pressed():
	game_over_popup.hide()
	_generate_board_data()
	_on_viewport_size_changed()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://navScreen/gameMode.tscn")
