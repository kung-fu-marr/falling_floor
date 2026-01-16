extends HBoxContainer

var coords: Vector2i

func _ready() -> void:
	TileUtils.key_obtained.connect(remove_lock)

func remove_lock() -> void:
	get_child(0).queue_free()
	if get_child_count() == 0:
		TileUtils.door_opened.emit(coords)
