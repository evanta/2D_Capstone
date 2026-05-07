extends Area2D

signal cleared
signal player_entered(body)
signal player_exited(body)

@export var defeated := false

var tracked_enemies: Array[Node2D] = []
var had_enemies := false


func _ready() -> void:
	collision_mask |= 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	for child in get_children():
		if child.is_in_group("enemy"):
			_track_enemy(child)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_entered.emit(body)
	elif body.is_in_group("enemy"):
		_track_enemy(body)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_exited.emit(body)
		print("exited boss area")


func _track_enemy(enemy: Node2D) -> void:
	if enemy in tracked_enemies:
		return

	tracked_enemies.append(enemy)
	had_enemies = true
	enemy.tree_exiting.connect(func(): _on_enemy_removed(enemy))


func _on_enemy_removed(enemy: Node2D) -> void:
	tracked_enemies.erase(enemy)

	if had_enemies and tracked_enemies.is_empty():
		defeated = true
		cleared.emit()
		_clear_tileset()


func _clear_tileset() -> void:
	_disable_tilemaps(self)


func _disable_tilemaps(node: Node) -> void:
	for child in node.get_children():
		if child is TileMapLayer:
			child.visible = false
			child.collision_enabled = false

		_disable_tilemaps(child)
