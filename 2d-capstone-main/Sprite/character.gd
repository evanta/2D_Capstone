extends CharacterBody2D

@onready var anim = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D
@export var cameraZoom: float = 1.1
@export var moveSpeed: float = 2.0

const tile_size = Vector2(32, 32)
const vector_down = Vector2(0, tile_size.y)
const vector_up = Vector2(0, -tile_size.y)
const vector_right = Vector2(tile_size.x, 0)
const vector_left = Vector2(-tile_size.x, 0)

var is_moving := false

func _ready():
	print("start")
	anim.speed_scale = moveSpeed
	camera_2d.zoom = Vector2(cameraZoom, cameraZoom)
	sprite.play("idle")

func _input(event):
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

func _move(direction: Vector2, anim_name: String):
	is_moving = true
	anim.play(anim_name)
	var tween = create_tween()
	tween.tween_property(self, "position", position + direction, 1.0 / moveSpeed)
	tween.finished.connect(func(): is_moving = false)
	
