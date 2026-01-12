extends Node

var tiles: TileMapLayer
var player: Node2D

func set_player_to_tile(tile_coords: Vector2, start_tile: bool = false) -> void:
	var local_pos = tiles.map_to_local(tile_coords)
	var target_pos = tiles.to_global(local_pos)
	player.global_position = target_pos
	player.target_tile_pos = target_pos
	player.tile = tile_coords
	player.target_tile = tile_coords
	if start_tile:
		player.starting_tile = tile_coords

func query_relative_tile(tile_coords: Vector2) -> TileData:
	return tiles.get_cell_tile_data(tile_coords)

func get_tile_global_pos(tile_coords: Vector2) -> Vector2:
	var local_pos := tiles.map_to_local(tile_coords)
	return tiles.to_global(local_pos)
