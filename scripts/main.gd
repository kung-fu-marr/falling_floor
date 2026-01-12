extends Node2D

@export var start_tile: Vector2 = Vector2(0,0)
@onready var player: CharacterBody2D = $Player
@onready var tiles: TileMapLayer = $TileMapLayer

const TILE_SIZE: float = 16.0

func _ready() -> void:
	TileUtils.player = player
	TileUtils.tiles = tiles
	TileUtils.set_player_to_tile(start_tile, true)
