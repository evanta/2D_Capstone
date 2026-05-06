extends Area2D

signal cleared
signal player_entered(body)
signal player_exited(body)

@export var defeated := false

var tracked_enemies: Array[Node2D] = []
var had_enemies := false

var boss = null
var boss_alive := false


func register_boss(_boss):
	boss = _boss
	boss_alive = true

	if not boss.defeated.is_connected(_on_boss_defeated):
		boss.defeated.connect(_on_boss_defeated)


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


func _on_boss_defeated():
	boss_alive = false
	_try_clear_room()


func _track_enemy(enemy: Node2D) -> void:
	if enemy in tracked_enemies:
		return

	tracked_enemies.append(enemy)
	had_enemies = true
	enemy.tree_exiting.connect(func(): _on_enemy_removed(enemy))


func _on_enemy_removed(enemy: Node2D) -> void:
	tracked_enemies.erase(enemy)
	_try_clear_room()


func _try_clear_room():
	if had_enemies and tracked_enemies.is_empty() and not boss_alive:
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
