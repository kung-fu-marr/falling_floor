extends TileMapLayer

var activated_tiles: Array[Vector2] = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for coords in activated_tiles:
		var data = get_cell_tile_data(coords)
		#var time := data.get_custom_data()
