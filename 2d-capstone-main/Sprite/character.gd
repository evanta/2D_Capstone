extends CharacterBody2D

@onready var anim = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D

@export var cameraZoom: float = 1.1
@export var moveSpeed: float = 2.0
@export var timeOffBeat: float = 0.15
@export var playerHealth: float = 100

@onready var tile_map: TileMapLayer = get_parent().get_node("LEVEL DESIGN/GroundTileMap")
const MISS_SCENE = preload("res://Sprite/MissText.tscn")
@onready var conductor = get_parent().get_node("Conductor")
var corrupt_areas: Array[Area2D] = []

var tile_size: Vector2
var vector_down: Vector2
var vector_up: Vector2
var vector_right: Vector2
var vector_left: Vector2

var is_moving := false
var instance = null
var in_corrupt_area := false

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
	corrupt_areas = get_parent().corrupt_areas
	for area in corrupt_areas:
		area.body_entered.connect(_on_corrupt_entered)
		area.body_exited.connect(_on_corrupt_exited)
	print("tile_size from TileMap: ", tile_size)
	print("character start position: ", position)


func _input(event):
	if not (event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left") or \
			event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down")):
		return
		
	if event.is_echo():
		return
	
	if in_corrupt_area and conductor != null and conductor.playing and conductor.seconds_to_beat() > timeOffBeat:
		_show_miss()
		playerHealth -= 5
		print(playerHealth)
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
	var miss = MISS_SCENE.instantiate()
	add_child(miss)
	var miss_anim: AnimationPlayer = miss.get_node("AnimationPlayer")
	var miss_sprite: Sprite2D = miss.get_node("Sprite2D")
	miss_sprite.modulate.a = 1.0
	miss_anim.play("MissFloat")
	await miss_anim.animation_finished
	var tween = create_tween()
	tween.tween_property(miss_sprite, "modulate:a", 0.0, 0.3)
	await tween.finished
	miss.queue_free()

func _move(direction: Vector2, anim_name: String):
	if test_move(transform, direction):
		return
	is_moving = true
	anim.play(anim_name)
	var tween = create_tween()
	var target = position + direction
	#print("moving to: ", target)
	tween.tween_property(self, "position", target, 0.5 / moveSpeed)
	tween.finished.connect(func(): is_moving = false)
	
func _on_corrupt_entered(body: Node2D) -> void:
	if body == self:
		in_corrupt_area = true
		print("entered corrupt area")

func _on_corrupt_exited(body: Node2D) -> void:
	if body == self:
		in_corrupt_area = false
		print("exited corrupt area")
