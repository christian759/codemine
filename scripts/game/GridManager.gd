extends Node
class_name GridManager

signal tile_revealed(is_mine: bool)
signal mine_exploded()
signal flag_toggled(is_placed: bool)
signal board_generated(width: int, height: int)

@export var tile_scene: PackedScene

var grid: Array = []
var width: int = Constants.DEFAULT_BOARD_WIDTH
var height: int = Constants.DEFAULT_BOARD_HEIGHT
var mine_count: int = Constants.DEFAULT_MINE_COUNT
var mines_placed: bool = false
var game_mode: Constants.GameMode = Constants.GameMode.CLASSIC

func _ready() -> void:
	add_to_group("GridManager")

func generate_grid(w: int, h: int, mines: int, mode: Constants.GameMode) -> void:
	clear_grid()
	width = w
	height = h
	mine_count = mines
	game_mode = mode
	mines_placed = false

	for x in range(width):
		var column = []
		for y in range(height):
			if not tile_scene:
				push_error("Tile scene not set in GridManager")
				return
			
			var tile: Node = tile_scene.instantiate()
			tile.grid_x = x
			tile.grid_y = y
			tile.state = Constants.TileState.HIDDEN
			tile.is_mine = false
			tile.neighbor_mines = 0
			
			tile.left_clicked.connect(_on_tile_left_clicked.bind(tile))
			tile.right_clicked.connect(_on_tile_right_clicked.bind(tile))
			tile.chord_requested.connect(_on_tile_chord_requested.bind(tile))
			
			add_child(tile)
			column.append(tile)
		grid.append(column)
		
	board_generated.emit(width, height)

func clear_grid() -> void:
	for child in get_children():
		child.queue_free()
	grid.clear()

func _on_tile_left_clicked(tile: Node) -> void:
	if tile.state == Constants.TileState.FLAGGED or tile.state == Constants.TileState.EXPLODED:
		return
		
	if not mines_placed:
		_place_mines(tile.grid_x, tile.grid_y)
		mines_placed = true
	
	if tile.is_mine:
		tile.state = Constants.TileState.EXPLODED
		mine_exploded.emit()
	else:
		_reveal_tile(tile)

func _on_tile_right_clicked(tile: Node) -> void:
	if tile.state == Constants.TileState.REVEALED or tile.state == Constants.TileState.EXPLODED:
		return
	
	if tile.state == Constants.TileState.HIDDEN:
		tile.state = Constants.TileState.FLAGGED
		flag_toggled.emit(true)
	elif tile.state == Constants.TileState.FLAGGED:
		tile.state = Constants.TileState.HIDDEN
		flag_toggled.emit(false)

func _on_tile_chord_requested(tile: Node) -> void:
	if tile.state != Constants.TileState.REVEALED or tile.neighbor_mines == 0:
		return
	
	var neighbors = _get_neighbors(tile.grid_x, tile.grid_y)
	var flag_count = 0
	for n in neighbors:
		if n.state == Constants.TileState.FLAGGED:
			flag_count += 1
			
	if flag_count == tile.neighbor_mines:
		for n in neighbors:
			if n.state == Constants.TileState.HIDDEN:
				_on_tile_left_clicked(n)

func _place_mines(safe_x: int, safe_y: int) -> void:
	var flat_coords = []
	for x in range(width):
		for y in range(height):
			if x != safe_x or y != safe_y:
				flat_coords.append(Vector2i(x,y))
				
	flat_coords.shuffle()
	
	for i in range(min(mine_count, flat_coords.size())):
		var pos = flat_coords[i]
		grid[pos.x][pos.y].is_mine = true
		
	# Calculate neighbors
	for x in range(width):
		for y in range(height):
			var tile = grid[x][y]
			if not tile.is_mine:
				tile.neighbor_mines = _count_neighbor_mines(x, y)

func _count_neighbor_mines(x: int, y: int) -> int:
	var count = 0
	for n in _get_neighbors(x, y):
		if n.is_mine:
			count += 1
	return count

func _get_neighbors(x: int, y: int) -> Array:
	var neighbors = []
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0: continue
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and nx < width and ny >= 0 and ny < height:
				neighbors.append(grid[nx][ny])
	return neighbors

func _reveal_tile(start_tile: Node) -> void:
	if start_tile.state != Constants.TileState.HIDDEN:
		return

	# Flood fill using a queue
	var queue = [start_tile]
	start_tile.state = Constants.TileState.REVEALED
	tile_revealed.emit(false)
	
	var head = 0
	while head < queue.size():
		var current = queue[head]
		head += 1
		
		if current.neighbor_mines == 0:
			for n in _get_neighbors(current.grid_x, current.grid_y):
				if n.state == Constants.TileState.HIDDEN and not n.is_mine:
					n.state = Constants.TileState.REVEALED
					tile_revealed.emit(false)
					queue.append(n)

func reveal_all_mines() -> void:
	for x in range(width):
		for y in range(height):
			var tile = grid[x][y]
			if tile.is_mine and tile.state != Constants.TileState.EXPLODED:
				tile.state = Constants.TileState.REVEALED

func flag_all_mines() -> void:
	for x in range(width):
		for y in range(height):
			var tile = grid[x][y]
			if tile.is_mine and tile.state == Constants.TileState.HIDDEN:
				_on_tile_right_clicked(tile)
