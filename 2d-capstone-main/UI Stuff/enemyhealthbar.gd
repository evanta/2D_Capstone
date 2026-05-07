extends ProgressBar

# Main bar = current HP
# DamageBar = white delayed bar

@onready var enemy = get_parent()
@onready var timer = get_node("Timer")
@onready var damage_bar = get_node("DamageBar")

func _ready() -> void:
	# Start hidden until enemy takes damage
	visible = false
	damage_bar.visible = false

	max_value = enemy.maxHealth
	damage_bar.max_value = enemy.maxHealth

	# Both bars start full
	value = enemy.currentHealth
	damage_bar.value = enemy.currentHealth

	enemy.healthChanged.connect(update_health)

func update_health() -> void:
	# Only show health bar after first hit
	if not visible and enemy.currentHealth < enemy.maxHealth:
		visible = true
		damage_bar.visible = true

	# Main bar updates instantly
	value = enemy.currentHealth

	# White bar delays before catching up
	if damage_bar.value > value:
		timer.start()
	else:
		damage_bar.value = value

	# Remove bar when enemy dies
	if enemy.currentHealth <= 0:
		queue_free()

func _on_timer_timeout() -> void:
	damage_bar.value = value
	
