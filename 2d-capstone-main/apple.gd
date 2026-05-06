extends Node2D

@export var heal_amount: int = 20

var player = null
var tile_size: Vector2 = Vector2(16, 16)


func _ready():
	player = get_tree().get_first_node_in_group("player")
	_snap_to_grid()


func _process(_delta):
	if player == null:
		return
	
	var target_cell = world_to_cell(global_position)
	_check_heal(target_cell)


# ========================
# HEAL
# ========================
func _check_heal(target_cell: Vector2):
	if player == null:
		return

	if world_to_cell(player.global_position) == target_cell:
		# Do not consume apple if player is already full health
		if player.currentHealth >= player.maxHealth:
			return

		# Heal without exceeding max health
		player.currentHealth = min(
			player.currentHealth + heal_amount,
			player.maxHealth
		)

		# Update health bar UI
		player.healthChanged.emit()

		print("Player healed for ", heal_amount)

		# Remove apple after pickup
		queue_free()


# ========================
# GRID HELPERS
# ========================
func world_to_cell(pos: Vector2) -> Vector2:
	return (pos / tile_size).floor()


func cell_to_world(cell: Vector2) -> Vector2:
	return cell * tile_size + tile_size / 2


func _snap_to_grid():
	global_position = cell_to_world(world_to_cell(global_position))
