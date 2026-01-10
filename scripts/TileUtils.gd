extends Node

@onready var tiles: TileMapLayer

func query_relative_tile(tile_coords: Vector2) -> TileData:
	return tiles.get_cell_tile_data(tile_coords)

func get_tile_global_pos(tile_coords: Vector2) -> Vector2:
	var local_pos := tiles.map_to_local(tile_coords)
	return tiles.to_global(local_pos)
