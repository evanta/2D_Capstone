extends Area2D

signal cleared

var tracked_enemies: Array[Node2D] = []
var had_enemies := false
@export var defeated := false

func _ready() -> void:
	collision_mask |= 2  # also monitor layer 2 so enemy bodies are detected
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	call_deferred("_scan_initial_enemies")

func _scan_initial_enemies() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("enemy") and body not in tracked_enemies:
			tracked_enemies.append(body)
			had_enemies = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("player entered")
	elif body.is_in_group("enemy"):
		if body not in tracked_enemies:
			tracked_enemies.append(body)
			had_enemies = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("player exited")
	elif body.is_in_group("enemy"):
		tracked_enemies.erase(body)
		if had_enemies and tracked_enemies.is_empty():
			cleared.emit()
			_clear_tileset()

func _clear_tileset() -> void:
	_disable_tilemaps(self)

func _disable_tilemaps(node: Node) -> void:
	defeated = true
	for child in node.get_children():
		if child is TileMapLayer:
			child.visible = false
			child.collision_enabled = false
		_disable_tilemaps(child)
