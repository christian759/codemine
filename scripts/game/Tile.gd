extends Control

signal left_clicked()
signal right_clicked()
signal chord_requested()

var grid_x: int
var grid_y: int
var neighbor_mines: int = 0
var is_mine: bool = false

var state: Constants.TileState = Constants.TileState.HIDDEN:
	set(value):
		if state != value:
			state = value
			_update_visuals()

var label: Label
var bg_rect: ColorRect
var tween: Tween

func _ready() -> void:
	custom_minimum_size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
	
	bg_rect = ColorRect.new()
	bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	# Default hidden color
	bg_rect.color = Color("#34495e")
	add_child(bg_rect)
	
	label = Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# A temporary modern font setting (would use a custom font in real)
	label.add_theme_font_size_override("font_size", 24)
	label.hide()
	add_child(label)
	
	# Handle input on background rect
	bg_rect.gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if state == Constants.TileState.REVEALED and neighbor_mines > 0:
				chord_requested.emit()
			else:
				left_clicked.emit()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			right_clicked.emit()
	
	# Mobile long press for flagging could be handled here with a timer
	# For simplicity, treating right-click as standard desktop flag
	# A full touch impl would tap to reveal, long touch to flag.

func _update_visuals() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	# Popping animation
	scale = Vector2(0.8, 0.8)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)
	
	match state:
		Constants.TileState.HIDDEN:
			bg_rect.color = Color("#34495e")
			label.hide()
		Constants.TileState.FLAGGED:
			bg_rect.color = Color("#e67e22")
			label.text = "🚩"
			label.show()
		Constants.TileState.EXPLODED:
			bg_rect.color = Color("#e74c3c")
			label.text = "💥"
			label.show()
		Constants.TileState.REVEALED:
			if is_mine:
				bg_rect.color = Color("#c0392b")
				label.text = "💣"
				label.show()
			else:
				bg_rect.color = Color("#ecf0f1")
				if neighbor_mines > 0:
					label.text = str(neighbor_mines)
					label.add_theme_color_override("font_color", _get_number_color(neighbor_mines))
					label.show()
				else:
					label.hide()

func _get_number_color(num: int) -> Color:
	match num:
		1: return Color("#3498db")
		2: return Color("#2ecc71")
		3: return Color("#e74c3c")
		4: return Color("#9b59b6")
		5: return Color("#f1c40f")
		6: return Color("#1abc9c")
		7: return Color("#34495e")
		8: return Color("#7f8c8d")
		_: return Color("#000000")
