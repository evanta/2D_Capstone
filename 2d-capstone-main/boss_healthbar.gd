extends TextureProgressBar

var boss = null


func _ready() -> void:
	# safer lookup
	boss = get_tree().get_first_node_in_group("boss")

	if boss == null:
		push_error("Boss not found in group 'boss'")
		return

	# connect safely
	if boss.has_signal("healthChanged"):
		boss.healthChanged.connect(update)

	value = 100
	update()


func update():
	if boss == null:
		return

	print("test")
	value = (boss.currentHealth * 100.0) / boss.maxHealth
