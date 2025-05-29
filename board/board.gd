extends Node2D

const WIDTH := 8
const HEIGHT := 8
const BOMB_COUNT := 10
const TILE_SIZE := 32 # or 64, match your button size
const HORIZONTAL_TILE_MARGIN := 20 # Adjust this value for more/less spacing
const VERTICAL_TILE_MARGIN := 20 # Adjust this value for more/less spacing

@onready var tile_scene := preload("res://board/TileButton.tscn")

var tiles := []
var tile_nodes := []

func _ready():
	generate_grid()
	get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed():
	clear_grid()
	generate_grid()

func clear_grid():
	for row in tile_nodes:
		for tile in row:
			if tile:
				tile.queue_free()
	tile_nodes.clear()

func generate_grid():
	# Step 1: Create tile data
	tiles.clear()
	tile_nodes.clear()
	for y in HEIGHT:
		var row = []
		var node_row = []
		for x in WIDTH:
			row.append(MineTileData.new())
			node_row.append(null)
		tiles.append(row)
		tile_nodes.append(node_row) # <-- Move this line here
	
	# Step 2: Place bombs randomly
	var placed := 0
	while placed < BOMB_COUNT:
		var rx = randi() % WIDTH
		var ry = randi() % HEIGHT
		if not tiles[ry][rx].is_bomb:
			tiles[ry][rx].is_bomb = true
			placed += 1

	# Step 3: Calculate neighbors
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

	# Calculate offset to center the grid (include margins)
	var grid_width = WIDTH * (TILE_SIZE + HORIZONTAL_TILE_MARGIN) - HORIZONTAL_TILE_MARGIN
	var grid_height = HEIGHT * (TILE_SIZE + VERTICAL_TILE_MARGIN ) - VERTICAL_TILE_MARGIN 
	var offset = Vector2(
		(self.get_viewport_rect().size.x - grid_width) / 2,
		(self.get_viewport_rect().size.y - grid_height) / 2
	)

	# Step 4: Instantiate buttons
	for y in HEIGHT:
		for x in WIDTH:
			var tile = tile_scene.instantiate()
			tile.x = x
			tile.y = y
			tile.grid_manager = self
			tile.position = Vector2(
				x * (TILE_SIZE + HORIZONTAL_TILE_MARGIN),
				y * (TILE_SIZE + VERTICAL_TILE_MARGIN )
			) + offset
			add_child(tile)
			tile_nodes[y][x] = tile

func is_valid(x, y):
	return x >= 0 and y >= 0 and x < WIDTH and y < HEIGHT

func reveal_tile(x, y):
	var data = tiles[y][x]
	var button = tile_nodes[y][x]

	if data.is_revealed or data.is_flagged:
		return

	data.is_revealed = true

	if data.is_bomb:
		button.text = "💣"
		button.disabled = true
		# TODO: game over logic
		return

	if data.neighbor_bombs > 0:
		button.text = str(data.neighbor_bombs)
	else:
		button.text = ""
		# Auto-reveal neighbors
		for ny in range(y - 1, y + 1):
			for nx in range(x - 1, x + 1):
				if is_valid(nx, ny):
					reveal_tile(nx, ny)

	button.disabled = true
