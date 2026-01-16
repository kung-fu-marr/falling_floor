extends Node2D

@export var floor_tiles: TileMapLayer
@export var item_tiles: TileMapLayer
@export var doors: Dictionary[String, Array] = {}
const LOCK_TEXTURE = preload("uid://bnicm3vdtinbu")
const KeyDisplay = preload("uid://c54cukopot31c")

var activated_floor_tiles: Array[Vector2i] = []
var activation_times: Dictionary = {}

func _ready() -> void:
	TileUtils.key_obtained.connect(_on_key_obtained)
	
	TileUtils.tile_manager = self
	TileUtils.floor_tiles = floor_tiles
	TileUtils.item_tiles = item_tiles
	
	lock_doors()
	
func _process(delta: float) -> void:
	for i in activated_floor_tiles.size():
		var coords = activated_floor_tiles[i]
		var tile = Vector2i(coords.x, coords.y)
		var tile_str = str(tile)
		var data = floor_tiles.get_cell_tile_data(tile)
		
		var activation_time = data.get_custom_data("activation_time")
		
		if activation_time > 0.0:
			activation_times[tile_str] += delta
		if data.get_custom_data("collapsing"):
			if activation_times[tile_str] < activation_time:
				continue
			var collapse_level = data.get_custom_data("collapse_level")
			if collapse_level == 3:
				floor_tiles.set_cell(tile, 0, Vector2i(8,7))
				activated_floor_tiles[i] = Vector2i(-1,-1)
				activation_times[tile_str] = -1
				continue
			floor_tiles.set_cell(tile, 1, Vector2i(collapse_level + 1, 0))
			
	clean_up_activated_floor_tiles()
	
func activate_floor_tile(tile_coords: Vector2i) -> void:
	activated_floor_tiles.append(Vector2i(tile_coords.x, tile_coords.y))
	var dict_str = str(tile_coords)
	activation_times[dict_str] = 0

func clean_up_activated_floor_tiles() -> void:
	for tile in activated_floor_tiles:
		if tile != Vector2i(-1, -1):
			continue
		activated_floor_tiles.erase(tile)
	
	for key in activation_times.keys():
		if activation_times[key] == -1:
			activation_times.erase(key)
			
func lock_doors() -> void:
	for door in doors.keys():
		var keys_arr := doors[door]
		var box := HBoxContainer.new()
		box.set_script(KeyDisplay)
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		for key in keys_arr:
			var temp_lock := TextureRect.new()
			temp_lock.texture = LOCK_TEXTURE
			box.add_child(temp_lock)
		$Locks.add_child(box)
		var coords = string_to_vector2(door)
		box.global_position = TileUtils.get_tile_global_pos(coords, "items")

func string_to_vector2(string := "") -> Vector2i:
	if string:
		var new_string: String = string
		new_string = new_string.erase(0, 1)
		print(new_string)
		new_string = new_string.erase(new_string.length() - 1, 1)
		print(new_string)
		var array: Array = new_string.split(", ")
		print(array)
		return Vector2(int(array[0]), int(array[1]))

	return Vector2.ZERO

func _on_key_obtained(coords) -> void:
	item_tiles.set_cell(coords)
	for tile in item_tiles.get_used_cells():
		var data = item_tiles.get_cell_tile_data(tile)
		var door = data.get_custom_data("door")
		if door:
			item_tiles.set_cell(tile, 0, Vector2i(9,3))
