extends CharacterBody2D

@onready var anim = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var conductor = get_parent().get_node("Conductor")

@onready var player = get_parent().get_node("Character")
@onready var tile_map: TileMapLayer = get_parent().get_node("LEVEL DESIGN/GroundTileMap")

var tile_size: Vector2

var vector_down: Vector2
var vector_up: Vector2
var vector_right: Vector2
var vector_left: Vector2

var is_moving := false


# ========================
# SETUP
# ========================
func _ready():
	if tile_map == null:
		push_warning("TileMap not found")
		return

	tile_size = Vector2(tile_map.tile_set.tile_size)

	vector_down = Vector2(0, tile_size.y)
	vector_up = Vector2(0, -tile_size.y)
	vector_right = Vector2(tile_size.x, 0)
	vector_left = Vector2(-tile_size.x, 0)

	sprite.play("idle")

	_snap_to_grid()

	conductor.beat.connect(_on_beat)


# ========================
# GRID HELPERS
# ========================
func world_to_cell(pos: Vector2) -> Vector2:
	return (pos / tile_size).floor()

func cell_to_world(cell: Vector2) -> Vector2:
	return cell * tile_size + tile_size / 2

func _snap_to_grid():
	global_position = cell_to_world(world_to_cell(global_position))


# ========================
# BEAT LOGIC (NECRODANCER STYLE)
# ========================
func _on_beat(_beat_index):
	if is_moving:
		return

	if player == null:
		return

	var enemy_cell = world_to_cell(global_position)
	var player_cell = world_to_cell(player.global_position)

	var diff = player_cell - enemy_cell

	var direction = Vector2.ZERO

	# axis priority chase (classic rhythm AI)
	if abs(diff.x) > abs(diff.y):
		direction = Vector2(sign(diff.x), 0)
	elif diff.y != 0:
		direction = Vector2(0, sign(diff.y))

	if direction != Vector2.ZERO:
		_move(direction)


# ========================
# JUMP MOVEMENT (RHYTHM HOP)
# ========================
func _move(direction: Vector2):
	is_moving = true

	var start_pos = global_position
	var target_pos = global_position + direction * tile_size

	anim.play(_get_anim_name(direction))

	var tween = create_tween()
	tween.tween_method(_jump_arc.bind(start_pos, target_pos), 0.0, 1.0, conductor.sec_per_beat)

	tween.finished.connect(_on_move_finished)


# ========================
# JUMP ARC (VISUAL RHYTHM HOP)
# ========================
func _jump_arc(t: float, start: Vector2, target: Vector2):
	var pos = start.lerp(target, t)

	# arc height (tweak for feel)
	var height = -tile_size.y * 0.35
	var arc = 4 * height * (t - t * t)

	global_position = pos + Vector2(0, arc)


# ========================
# FINISH MOVE
# ========================
func _on_move_finished():
	is_moving = false

	# hard snap to grid to prevent drift
	global_position = cell_to_world(world_to_cell(global_position))

	sprite.play("idle")


# ========================
# ANIMATION
# ========================
func _get_anim_name(direction: Vector2) -> String:
	if direction == vector_right:
		sprite.flip_h = false
		return "MoveRight"
	elif direction == vector_left:
		sprite.flip_h = true
		return "MoveLeft"
	elif direction == vector_up:
		return "MoveUp"
	elif direction == vector_down:
		return "MoveDown"
	return "idle"
