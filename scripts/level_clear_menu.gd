extends CanvasLayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
