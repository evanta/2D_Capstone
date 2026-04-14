extends CharacterBody2D

@onready var anim = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D

@export var cameraZoom: float = 1.1
@export var moveSpeed: float = 2.0
@export var XgridOffset: float = 1.0 #adjust the x position of the characture on the grid
@export var YgridOffset: float = 1.0 #adjust the y position of the characture on the grid

@onready var tile_map: TileMapLayer = get_parent().get_node("LEVEL DESIGN/GroundTileMap") #add the path to the tile map that you want the characture to snap to.

var tile_size: Vector2
var vector_down: Vector2
var vector_up: Vector2
var vector_right: Vector2
var vector_left: Vector2

var is_moving := false

func _ready():
	tile_size = Vector2(tile_map.tile_set.tile_size)
	vector_down = Vector2(0, tile_size.y)
	vector_up = Vector2(0, -tile_size.y)
	vector_right = Vector2(tile_size.x, 0)
	vector_left = Vector2(-tile_size.x, 0)
	position = position.snapped(tile_size) + Vector2(tile_size.x / XgridOffset, tile_size.y / YgridOffset)
	anim.speed_scale = moveSpeed
	camera_2d.zoom = Vector2(cameraZoom, cameraZoom)
	sprite.play("idle")
	print("tile_size from TileMap: ", tile_size)
	print("character start position: ", position)


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
	var target = position + direction
	print("moving to: ", target)
	tween.tween_property(self, "position", target, 1.0 / moveSpeed)
	tween.finished.connect(func(): is_moving = false)
	
