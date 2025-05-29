extends Node2D

const WIDTH := 8
const HEIGHT := 8
const BOMB_COUNT := 10
const TILE_SIZE := 32
const HORIZONTAL_TILE_MARGIN := 20
const VERTICAL_TILE_MARGIN := 20

@onready var tile_scene = preload("res://board/TileButton.tscn")

var tiles = []
var tile_nodes = []

@onready var game_over_popup: PopupPanel = $PopupPanel
@onready var restart_button: Button = $PopupPanel/VBoxContainer/HBoxContainer/RestartButton
@onready var back_button: Button = $PopupPanel/VBoxContainer/HBoxContainer/BackButton

func _ready():
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_generate_board_data()
	_on_viewport_size_changed()
	restart_button.pressed.connect(_on_restart_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_viewport_size_changed():
	clear_grid()
	generate_grid()

func _generate_board_data():
	tiles.clear()
	for y in HEIGHT:
		var row = []
		for x in WIDTH:
			row.append(MineTileData.new())
		tiles.append(row)

	# Place bombs randomly
	var placed := 0
	while placed < BOMB_COUNT:
		var rx = randi() % WIDTH
		var ry = randi() % HEIGHT
		if not tiles[ry][rx].is_bomb:
			tiles[ry][rx].is_bomb = true
			placed += 1

	# Calculate neighbors
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

func generate_grid():
	tile_nodes.clear()
	var grid_width = WIDTH * (TILE_SIZE + HORIZONTAL_TILE_MARGIN) - HORIZONTAL_TILE_MARGIN
	var grid_height = HEIGHT * (TILE_SIZE + VERTICAL_TILE_MARGIN) - VERTICAL_TILE_MARGIN
	var offset = Vector2(
		(self.get_viewport_rect().size.x - grid_width) / 2,
		(self.get_viewport_rect().size.y - grid_height) / 2
	)
	for y in HEIGHT:
		var node_row = []
		for x in WIDTH:
			var tile = tile_scene.instantiate()
			tile.x = x
			tile.y = y
			tile.grid_manager = self
			tile.position = Vector2(
				x * (TILE_SIZE + HORIZONTAL_TILE_MARGIN),
				y * (TILE_SIZE + VERTICAL_TILE_MARGIN)
			) + offset
			# Restore revealed state
			var data = tiles[y][x]
			if data.is_revealed:
				if data.is_bomb:
					tile.text = "💣"
				elif data.neighbor_bombs > 0:
					tile.text = str(data.neighbor_bombs)
				else:
					tile.text = ""
				tile.disabled = true
			node_row.append(tile)
			add_child(tile)
		tile_nodes.append(node_row)

func reveal_tile(x, y):
	var data = tiles[y][x]
	var button = tile_nodes[y][x]

	if data.is_revealed or data.is_flagged:
		return

	data.is_revealed = true

	if data.is_bomb:
		button.text = "💣"
		button.disabled = true
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
					reveal_tile(nx, ny)
	button.disabled = true

func _disable_all_tiles():
	for row in tile_nodes:
		for tile in row:
			tile.disabled = true

func is_valid(x, y):
	return x >= 0 and x < WIDTH and y >= 0 and y < HEIGHT

func _show_game_over_popup():
	game_over_popup.popup_centered()

func _on_restart_pressed():
	game_over_popup.hide()
	_generate_board_data()
	_on_viewport_size_changed()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://navScreen/gameMode.tscn")
