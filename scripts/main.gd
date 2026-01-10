extends Node2D

@export var start_tile: Vector2 = Vector2(0,0)
@onready var player: CharacterBody2D = $Player
@onready var tiles: TileMapLayer = $TileMapLayer

const TILE_SIZE: float = 16.0

func _ready() -> void:
	TileUtils.tiles = tiles
	set_player_to_tile(start_tile)

func set_player_to_tile(tile_coords: Vector2) -> void:
	var local_pos = tiles.map_to_local(tile_coords)
	var target_pos = self.to_global(local_pos)
	player.global_position = target_pos
	player.tile = tile_coords
