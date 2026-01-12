extends TileMapLayer

var activated_tiles: Array[Vector2i] = []
var activation_times: Dictionary = {}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in activated_tiles.size():
		var coords = activated_tiles[i]
		var tile = Vector2i(coords.x, coords.y)
		var tile_str = str(tile)
		var data = get_cell_tile_data(tile)
		
		var activation_time = data.get_custom_data("activation_time")
		
		if activation_time > 0.0:
			activation_times[tile_str] += delta
		if data.get_custom_data("collapsing"):
			if activation_times[tile_str] < activation_time:
				continue
			var collapse_level = data.get_custom_data("collapse_level")
			if collapse_level == 3:
				set_cell(tile, 0, Vector2i(8,7))
				activated_tiles[i] = Vector2i(-1,-1)
				activation_times[tile_str] = -1
				continue
			set_cell(tile, 1, Vector2i(collapse_level + 1, 0))
			
	clean_up_activated_tiles()
	
func activate_tile(tile_coords: Vector2i) -> void:
	activated_tiles.append(Vector2i(tile_coords.x, tile_coords.y))
	var dict_str = str(tile_coords)
	activation_times[dict_str] = 0

func clean_up_activated_tiles() -> void:
	for tile in activated_tiles:
		if tile != Vector2i(-1, -1):
			continue
		activated_tiles.erase(tile)
	
	for key in activation_times.keys():
		if activation_times[key] == -1:
			activation_times.erase(key)
			
		
