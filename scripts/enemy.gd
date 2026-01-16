extends CharacterBody2D


enum STATE {STAND, MOVE, FALL}

const SPEED := 20.0

@export var start_tile: Vector2i
@export var tile_path: Array[Vector2i]
var target_index: int = 0
@export var target_snap: float = 0.2

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimatedSprite2D/AnimationPlayer

var current_state: STATE = STATE.STAND
var starting_tile: Vector2i = Vector2i.ZERO
var tile: Vector2i = Vector2i.ZERO
var target_tile: Vector2i = Vector2i.ZERO
var target_tile_pos: Vector2 = Vector2.ZERO
var reverse_path: bool = false

func _ready() -> void:
	TileUtils.set_character_to_tile(self, start_tile)

func _physics_process(delta: float) -> void:
	process_state(delta)

func switch_state(to_state: STATE):
	current_state = to_state
	match current_state:
		STATE.STAND:
			anim_sprite.play("default")
			velocity = Vector2.ZERO
			global_position = target_tile_pos
			tile = target_tile
			if tile == tile_path[target_index]:
				if reverse_path == true:
					target_index -= 1
					if target_index <= 0:
						reverse_path = false
						target_index = 0
				else:
					target_index += 1
				if target_index >= tile_path.size():
					target_index = 0
			
		STATE.MOVE:
			pass
		
		STATE.FALL:
			anim_sprite.play("fall")
			anim_player.play("fall")
			
func process_state(delta) -> void:
	match current_state:
		STATE.STAND:
			if not check_if_pit():
				handle_movement(delta)

		STATE.MOVE:
			move_and_slide()
			if global_position.distance_to(target_tile_pos) <= target_snap:				
				switch_state(STATE.STAND)

		STATE.FALL:
			if not anim_player.is_playing():
				TileUtils.set_character_to_tile(self, starting_tile)
				queue_free()
			
func handle_movement(_delta) -> void:
	var dir := (tile_path[target_index] - tile)
	dir /= dir.length()
	
	if dir == Vector2i.ZERO:
		return
		
	if !check_valid_tile(dir):
		reverse_path = true
		target_index -= 1
		if target_index <= 0:
			target_index = 0
			reverse_path = false
		dir = (tile_path[target_index] - tile)
		if dir != Vector2i.ZERO:
			dir /= dir.length()
	
	var mov := Vector2i.ZERO
	if dir.x:
		if dir.x > 0:
			anim_sprite.flip_h = false
		else:
			anim_sprite.flip_h = true
		mov.x = dir.x
	elif dir.y:
		mov.y = dir.y

	target_tile = tile + mov
	target_tile_pos = TileUtils.get_tile_global_pos(target_tile, "floor")
	
	velocity = mov * SPEED
	move_and_slide()
	switch_state(STATE.MOVE)

func check_valid_tile(dir: Vector2i) -> bool:
	var data: TileData
	if dir.x:
		data = TileUtils.query_relative_tile(Vector2i(tile.x + dir.x, tile.y))
	else:
		data = TileUtils.query_relative_tile(Vector2i(tile.x, tile.y + dir.y))
	var is_wall: bool = data.get_custom_data("wall")
	return !is_wall

func check_if_pit() -> bool:
	var data: TileData = TileUtils.query_relative_tile(tile)
	var is_pit: bool = data.get_custom_data("pit")
	if is_pit:
		switch_state(STATE.FALL)
		return true
	return false
