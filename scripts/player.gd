extends CharacterBody2D

enum STATE {STAND, MOVE, FALL}
enum FACING {UP, DOWN, LEFT, RIGHT}

const NORMAL_SPEED := 70.0
const SLOW_SPEED := NORMAL_SPEED * 0.6

@export var target_snap: float = 1.0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimatedSprite2D/AnimationPlayer

var current_state: STATE = STATE.STAND
var starting_tile: Vector2i = Vector2i.ZERO
var tile: Vector2i = Vector2i.ZERO
var target_tile: Vector2i = Vector2i.ZERO
var target_tile_pos: Vector2 = Vector2.ZERO
var is_carrying_key: bool = false

#func _ready() -> void:
	#switch_state(STATE.STAND)
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		is_carrying_key = !is_carrying_key
	process_state(delta)

func switch_state(to_state: STATE):
	current_state = to_state
	match current_state:
		STATE.STAND:
			anim_sprite.play("default")
			velocity = Vector2.ZERO
			global_position = target_tile_pos
			tile = target_tile
			TileUtils.step_on_tile(tile)
			
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
				TileUtils.set_player_to_tile(starting_tile)
				get_tree().reload_current_scene()
				#anim_player.play("RESET")
				#switch_state(STATE.STAND)
			
func handle_movement(_delta) -> void:
	var dir := Vector2i(
		signi(Input.get_axis("ui_left", "ui_right")),
		signi(Input.get_axis("ui_up", "ui_down"))
	)
	if dir == Vector2i.ZERO:
		return
		
	var valid: bool = check_valid_tile(dir) 
	if not valid:
		return
		
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
	target_tile_pos = TileUtils.get_tile_global_pos(target_tile)
	if not is_carrying_key:
		velocity = mov * NORMAL_SPEED
	else:
		velocity = mov * SLOW_SPEED
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
