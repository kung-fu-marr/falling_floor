extends CharacterBody2D

enum STATE {STAND, MOVE, FALL}
enum FACING {UP, DOWN, LEFT, RIGHT}

const NORMAL_SPEED := 70.0
const SLOW_SPEED := NORMAL_SPEED * 0.6

@export var target_snap: float = 1.0

var current_state: STATE = STATE.STAND
var tile: Vector2 = Vector2.ZERO
var target_tile: Vector2 = Vector2.ZERO
var target_tile_pos: Vector2 = Vector2.ZERO
var is_carrying_key: bool = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		is_carrying_key = !is_carrying_key
	process_state(delta)

func process_state(delta) -> void:
	match current_state:
		STATE.STAND:
			handle_movement(delta)

		STATE.MOVE:
			move_and_slide()
			if global_position.distance_to(target_tile_pos) <= target_snap:
				switch_state(STATE.STAND)

func switch_state(to_state: STATE):
	current_state = to_state
	match current_state:
		STATE.STAND:
			velocity = Vector2.ZERO
			global_position = target_tile_pos
			tile = target_tile
			
		STATE.MOVE:
			pass

func handle_movement(_delta) -> void:
	var dir := Vector2(
		signf(Input.get_axis("ui_left", "ui_right")),
		signf(Input.get_axis("ui_up", "ui_down"))
	)
	if dir == Vector2.ZERO:
		return
		
	var valid: bool = check_valid_tile(dir) 
	if not valid:
		return
		
	var mov := Vector2.ZERO
	if dir.x:
		mov.x = dir.x
	elif dir.y:
		mov.y = dir.y

	target_tile = tile + mov
	target_tile_pos = TileUtils.get_tile_global_pos(target_tile)
	if not is_carrying_key:
		velocity = mov * NORMAL_SPEED
	else:
		velocity = mov * SLOW_SPEED
	move_and_slide()
	switch_state(STATE.MOVE)

func check_valid_tile(dir: Vector2) -> bool:
	var data: TileData
	if dir.x:
		data = TileUtils.query_relative_tile(Vector2(tile.x + dir.x, tile.y))
	else:
		data = TileUtils.query_relative_tile(Vector2(tile.x, tile.y + dir.y))
	var is_wall: bool = data.get_custom_data("wall")
	return !is_wall
