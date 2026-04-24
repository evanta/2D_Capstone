extends TextureProgressBar

@onready var player = get_tree().get_nodes_in_group("player")[0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.healthChanged.connect(update)
	update()
	value = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update():
	value = player.currentHealth * 100 / player.maxHealth
