extends Node2D

@export var start_tile: Vector2i = Vector2i(1,1)
@onready var player: CharacterBody2D = $Player
const TILE_SIZE: float = 16.0

func _ready() -> void:
	TileUtils.player = player
	TileUtils.set_player_to_tile(start_tile, true)
