extends CharacterBody2D

@onready var anim = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D

@export var cameraZoom: float = 1.1
@export var moveSpeed: float = 2.0
@export var timeOffBeat: float = 0.15

@onready var tile_map: TileMapLayer = get_parent().get_node("LEVEL DESIGN/GroundTileMap") #add the path to the tile map that you want the characture to snap to.
@onready var MissAnim = $MissText/AnimationPlayer
@onready var MissSprite = $MissText/Sprite2D
@onready var conductor = get_parent().get_node("Conductor")

var tile_size: Vector2
var vector_down: Vector2
var vector_up: Vector2
var vector_right: Vector2
var vector_left: Vector2

var is_moving := false
var instance = null

func _ready():
	if tile_map == null:
		push_warning("tile_map not found — running without a TileMap parent")
		return
	tile_size = Vector2(tile_map.tile_set.tile_size)
	vector_down = Vector2(0, tile_size.y)
	vector_up = Vector2(0, -tile_size.y)
	vector_right = Vector2(tile_size.x, 0)
	vector_left = Vector2(-tile_size.x, 0)
	var tilemap_offset = tile_map.position
	position = (position - tilemap_offset).snapped(tile_size) + tilemap_offset + tile_size / 2
	anim.speed_scale = moveSpeed
	camera_2d.zoom = Vector2(cameraZoom, cameraZoom)
	sprite.play("idle")
	MissSprite.modulate.a = 0
	print("tile_size from TileMap: ", tile_size)
	print("character start position: ", position)


func _input(event): #if the play tries to move not on beat, this function returns. When the Music stops, the player can move freely
	if conductor != null and conductor.playing and conductor.seconds_to_beat() > timeOffBeat:
		_show_miss()
		return

	if is_moving:
		return
	if event.is_action_pressed("ui_right"):
		sprite.flip_h = false
		_move(vector_right, "MoveRight")
	elif event.is_action_pressed("ui_left"):
		sprite.flip_h = true
		_move(vector_left, "MoveLeft")
	elif event.is_action_pressed("ui_up"):
		_move(vector_up, "MoveUp")
	elif event.is_action_pressed("ui_down"):
		_move(vector_down, "MoveDown")

func _show_miss():
	#if MissAnim.is_playing():
	#	return
	MissSprite.modulate.a = 1.0
	MissAnim.play("MissFloat")
	await MissAnim.animation_finished
	var tween = create_tween()
	tween.tween_property(MissSprite, "modulate:a", 0.0, 0.3)

func _move(direction: Vector2, anim_name: String):
	if test_move(transform, direction):
		return  # blocked by a collision tile
	is_moving = true
	anim.play(anim_name)
	var tween = create_tween()
	var target = position + direction
	print("moving to: ", target)
	tween.tween_property(self, "position", target, 0.5 / moveSpeed)
	tween.finished.connect(func(): is_moving = false)
	
