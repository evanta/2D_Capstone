extends CharacterBody2D

signal healthChanged

@onready var anim = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D

@export var cameraZoom: float = 1.1
@export var moveSpeed: float = 2.0 #how fast does the player move
@export var timeOffBeat: float = 0.15 #how off beat the player can input movement and the character still move
@export var maxHealth: float = 100 #Important for health bar UI. DONT DELETE
@export var currentHealth: float = maxHealth #Tracks current healt. 
@export var offBeatDamage: int = 5

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
var is_invincible = false
var is_dead = false
@export var invincible_time = 0.5

func _ready():
	add_to_group("player")
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
	
	if not is_invincible and in_corrupt_area and conductor != null and conductor.playing and conductor.seconds_to_beat() > timeOffBeat:
		_show_miss()
		take_damage(10)
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
	var collision = move_and_collide(direction, true)
	if collision != null and not collision.get_collider().is_in_group("enemy"):
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
		
# ===== Damage & Health =====
func take_damage(amount):
	if is_invincible or is_dead:
		return

	is_invincible = true
	start_invincibility()

	currentHealth -= amount
	healthChanged.emit()
	print(currentHealth)

	if currentHealth <= 0:
		is_dead = true

func start_invincibility():
	if sprite:
		sprite.modulate = Color(1, 0.5, 0.5)  # Flash red

	await get_tree().create_timer(invincible_time).timeout
	is_invincible = false

	if sprite:
		sprite.modulate = Color(1, 1, 1)  # Back to normal
