extends Node

signal key_obtained(coords)
signal exit_reached(coords)

var tile_manager: Node2D
var floor_tiles: TileMapLayer
var item_tiles: TileMapLayer
var player: Node2D

func set_player_to_tile(tile_coords: Vector2i, start_tile: bool = false) -> void:
	var local_pos = floor_tiles.map_to_local(tile_coords)
	var target_pos = floor_tiles.to_global(local_pos)
	player.global_position = target_pos
	player.target_tile_pos = target_pos
	player.tile = tile_coords
	player.target_tile = tile_coords
	if start_tile:
		player.starting_tile = tile_coords

func query_relative_tile(tile_coords: Vector2i) -> TileData:
	return floor_tiles.get_cell_tile_data(tile_coords)

func get_tile_global_pos(tile_coords: Vector2i) -> Vector2:
	var local_pos := floor_tiles.map_to_local(tile_coords)
	return floor_tiles.to_global(local_pos)

func step_on_tile(tile_coords: Vector2i) -> void:
	check_item_tiles(tile_coords)
	check_floor_tiles(tile_coords)
	
func check_item_tiles(tile_coords) -> void:
	if tile_coords not in item_tiles.get_used_cells():
		return
	var item_data = item_tiles.get_cell_tile_data(tile_coords)
	if item_data.get_custom_data("exit"):
		exit_reached.emit(tile_coords)
	elif item_data.get_custom_data("key"):
		key_obtained.emit(tile_coords)

func check_floor_tiles(tile_coords) -> void:
	if tile_coords not in floor_tiles.get_used_cells():
		return
	var floor_data = floor_tiles.get_cell_tile_data(tile_coords)
	if floor_data.get_custom_data("activation_time") > 0.0:
		if tile_coords in tile_manager.activated_floor_tiles:
			print('duplicate prevented')
			return
		tile_manager.activate_floor_tile(tile_coords)
