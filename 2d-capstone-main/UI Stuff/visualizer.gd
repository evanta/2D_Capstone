extends Control

@export var bpm: float = 120.0
@export var beats_ahead: int = 2

@onready var left_spawn = $LeftSpawn
@onready var right_spawn = $RightSpawn
@onready var center_circle = $CenterCircle
@onready var music = $Conductor

var beat_bar_scene = preload("res://UI Stuff/BeatBar.tscn")

var beat_interval: float
var beat_timer: float = 0.0

var travel_time: float = 0.0
var in_corrupted_area: bool = false

var base_circle_scale: Vector2
var flash_tween: Tween

func _ready():
	beat_interval = 60.0 / bpm
	base_circle_scale = center_circle.scale

	visible = false  # start hidden

	# connect to player signal
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.corruption_changed.connect(_on_corruption_changed)

func _process(delta):
	if not in_corrupted_area:
		return

	beat_timer += delta

	if beat_timer >= beat_interval:
		beat_timer -= beat_interval

		travel_time = beat_interval * beats_ahead
		spawn_beat_bars()
		flash_center()

func spawn_beat_bars():
	spawn_bar(left_spawn.position)
	spawn_bar(right_spawn.position)

func spawn_bar(start_pos: Vector2):
	var bar = beat_bar_scene.instantiate()
	bar.position = start_pos
	bar.target_position = center_circle.position

	var distance = start_pos.distance_to(center_circle.position)
	bar.move_speed = distance / travel_time

	bar.z_index = 0
	add_child(bar)

func flash_center():
	if flash_tween and flash_tween.is_running():
		flash_tween.kill()

	center_circle.scale = base_circle_scale * 1.2

	flash_tween = create_tween()
	flash_tween.tween_property(
		center_circle,
		"scale",
		base_circle_scale,
		0.15
	)

func _on_corruption_changed(state: bool):
	in_corrupted_area = state
	visible = state

	if state:
		beat_timer = 0.0  # resync when entering area
