extends Node2D

@export var start_tile: Vector2i = Vector2i(1,1)
@export var doors: Dictionary[String, Array] = {}
@export var menu: CanvasLayer 
@onready var player: CharacterBody2D = $Player

const TILE_SIZE: float = 16.0

func _ready() -> void:
	get_tree().paused = false
	TileUtils.exit_reached.connect(_on_exit_reached)
	TileUtils.player = player
	TileUtils.set_character_to_tile(player, start_tile, true)
	
func _on_exit_reached(_coords) -> void:
	get_tree().paused = true
	menu.show()
