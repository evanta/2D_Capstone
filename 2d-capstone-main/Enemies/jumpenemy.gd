extends CharacterBody2D

@onready var anim = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var conductor = get_parent().get_parent().get_parent().get_node("Conductor")

@onready var player = get_tree().get_first_node_in_group("player")
@onready var tile_map: TileMapLayer = get_parent().get_parent().get_node("GroundTileMap")
@onready var corrupt_map: TileMapLayer = get_parent().get_node("CorruptMapLayer")

var tile_size: Vector2

var is_moving := false
var can_damage := true
var attack_cooldown_beats := 0

@export var damage: float = 10 #damage that the enemy does to the player

@export var speed: float = 1 #how fast does the enemy move twords and attack the player
#smaller number means slower

# ========================
# SETUP
# ========================
func _ready():
	add_to_group("enemy")

	tile_size = Vector2(tile_map.tile_set.tile_size)

	sprite.play("idle")
	_snap_to_grid()

	conductor.beat.connect(_on_beat)


# ========================
# GRID
# ========================
func world_to_cell(pos: Vector2) -> Vector2:
	return (pos / tile_size).floor()

func cell_to_world(cell: Vector2) -> Vector2:
	return cell * tile_size + tile_size / 2

func _snap_to_grid():
	global_position = cell_to_world(world_to_cell(global_position))


# ========================
# CORRUPTION RULE
# ========================
func is_corrupt(cell: Vector2) -> bool:
	var world_pos = cell_to_world(cell)
	var map_pos = corrupt_map.local_to_map(corrupt_map.to_local(world_pos))
	return corrupt_map.get_cell_source_id(map_pos) != -1


# ========================
# OCCUPANCY
# ========================
func is_cell_occupied(cell: Vector2) -> bool:
	for e in get_tree().get_nodes_in_group("enemy"):
		if e != self and world_to_cell(e.global_position) == cell:
			return true
	return false


# ========================
# BEAT AI
# ========================
func _on_beat(_beat_index):
	if attack_cooldown_beats > 0:
		attack_cooldown_beats -= 1

	if is_moving or player == null:
		return

	var enemy_cell = world_to_cell(global_position)
	var player_cell = world_to_cell(player.global_position)

	if not is_corrupt(enemy_cell):
		return

	if not is_corrupt(player_cell):
		return

	var diff = player_cell - enemy_cell
	var direction = Vector2.ZERO

	if abs(diff.x) > abs(diff.y):
		direction = Vector2(sign(diff.x), 0)
	elif diff.y != 0:
		direction = Vector2(0, sign(diff.y))

	var target_cell = enemy_cell + direction

	if is_corrupt(target_cell):
		_move(direction)


# ========================
# MOVE (JUMP)
# ========================
func _move(direction: Vector2):
	is_moving = true

	var start_cell = world_to_cell(global_position)
	var target_cell = start_cell

	if abs(direction.x) > abs(direction.y):
		target_cell += Vector2(sign(direction.x), 0)
	else:
		target_cell += Vector2(0, sign(direction.y))

	if not is_corrupt(target_cell):
		is_moving = false
		return

	if is_cell_occupied(target_cell):
		is_moving = false
		return

	var start_pos = cell_to_world(start_cell)
	var target_pos = cell_to_world(target_cell)

	anim.play(_get_anim_name(direction))

	if player != null and world_to_cell(player.global_position) == target_cell:
		_check_damage(target_cell)
		var lunge_pos = start_pos.lerp(target_pos, 0.4)
		var tween = create_tween()
		tween.tween_property(self, "global_position", lunge_pos, conductor.sec_per_beat / speed * 0.3)
		tween.tween_property(self, "global_position", start_pos, conductor.sec_per_beat / speed * 0.3)
		tween.finished.connect(_on_move_finished)
		return

	var tween = create_tween()
	tween.tween_method(_jump_arc.bind(start_pos, target_pos), 0.0, 1.0, conductor.sec_per_beat / speed)
	tween.finished.connect(_on_move_finished)


# ========================
# JUMP ARC
# ========================
func _jump_arc(t: float, start: Vector2, target: Vector2):
	var pos = start.lerp(target, t)

	var height = -tile_size.y * 0.35
	var arc = 4 * height * (t - t * t)

	global_position = pos + Vector2(0, arc)


# ========================
# DAMAGE
# ========================
func _check_damage(target_cell: Vector2):
	if not can_damage or player == null:
		return

	if attack_cooldown_beats > 0:
		return

	if world_to_cell(player.global_position) == target_cell:
		player.take_damage(damage)
		attack_cooldown_beats = 2
		_start_damage_cooldown()


func _start_damage_cooldown():
	can_damage = false
	await get_tree().create_timer(0.5).timeout
	can_damage = true


# ========================
# KNOCKBACK
# ========================
func _knockback(direction: Vector2):
	is_moving = true

	var start_cell = world_to_cell(global_position)
	var target_cell = _find_knockback_cell(start_cell, direction)

	var start_pos = cell_to_world(start_cell)
	var target_pos = cell_to_world(target_cell)

	var tween = create_tween()
	tween.tween_method(_jump_arc.bind(start_pos, target_pos), 0.0, 1.0, conductor.sec_per_beat / speed * 0.4)

	tween.finished.connect(func():
		is_moving = false
		global_position = target_pos
	)


func _find_knockback_cell(start_cell: Vector2, direction: Vector2) -> Vector2:
	var options = []

	if abs(direction.x) > abs(direction.y):
		options = [
			start_cell + Vector2(sign(direction.x), 0),
			start_cell + Vector2(0, 1),
			start_cell + Vector2(0, -1)
		]
	else:
		options = [
			start_cell + Vector2(0, sign(direction.y)),
			start_cell + Vector2(1, 0),
			start_cell + Vector2(-1, 0)
		]

	for c in options:
		if is_corrupt(c) and not is_cell_occupied(c):
			return c

	return start_cell


# ========================
# FINISH
# ========================
func _on_move_finished():
	is_moving = false
	global_position = cell_to_world(world_to_cell(global_position))
	sprite.play("idle")


func _get_anim_name(direction: Vector2) -> String:
	if direction == Vector2.RIGHT:
		sprite.flip_h = false
		return "MoveRight"
	elif direction == Vector2.LEFT:
		sprite.flip_h = true
		return "MoveLeft"
	elif direction == Vector2.UP:
		return "MoveUp"
	elif direction == Vector2.DOWN:
		return "MoveDown"
	return "idle"
