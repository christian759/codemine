extends Node

enum GameMode {
	CLASSIC,
	TIMED,
	SURVIVAL,
	LIMITED_VISION
}

enum TileState {
	HIDDEN,
	REVEALED,
	FLAGGED,
	EXPLODED # Only used for a mine that ended the game
}

const DEFAULT_BOARD_WIDTH = 9
const DEFAULT_BOARD_HEIGHT = 9
const DEFAULT_MINE_COUNT = 10

const TILE_SIZE = 64
