extends StaticBody2D

signal healthChanged
signal defeated
signal player_entered(body)
signal player_exited(body)

@export var MuckScene = preload("res://purple_muck.tscn")
@export var damage: float = 10
@export var maxHealth: float = 10
@export var currentHealth: float = maxHealth

@onready var animated_sprite = $BossSprite
@onready var explosion_sprite = $ExplosionSprite
@onready var shooter = $Shooter
@onready var boss_area = get_parent()

var player = null
var player_in_area := false
var is_dead := false

var beat_counter := 0
var conductor = null


func _ready():
	currentHealth = maxHealth

	# Room / area detection
	boss_area.body_entered.connect(_on_body_entered)
	boss_area.body_exited.connect(_on_body_exited)

	# Get conductor safely (no hard path)
	conductor = get_tree().get_first_node_in_group("conductor")
	if conductor:
		conductor.beat.connect(_on_beat)

	# visuals
	explosion_sprite.hide()
	animated_sprite.play("close")

	# IMPORTANT: register boss in room tracking system
	get_parent()._track_enemy(self)


# =========================
# PLAYER DETECTION
# =========================
func _on_body_entered(body):
	if body.is_in_group("player") and not is_dead:
		player_entered.emit(body)
		player = body
		player_in_area = true

		animated_sprite.play("open")
		await animated_sprite.animation_finished

		if player_in_area:
			animated_sprite.play("idle")


func _on_body_exited(body):
	if body == player:
		player_exited.emit(body)
		player_in_area = false
		player = null
		animated_sprite.play("close")


# =========================
# 4-BEAT SHOOTING
# =========================
func _on_beat(_beat):
	if is_dead:
		return

	if not player_in_area:
		return

	if player == null:
		return

	beat_counter += 1

	if beat_counter >= 4:
		beat_counter = 0
		shoot()


func shoot():
	if player == null:
		return

	var muck = MuckScene.instantiate()
	muck.damage = damage
	muck.fired_by = self

	var from = shooter.global_position
	var dir = (player.global_position - from).normalized()

	muck.global_position = from
	muck.velocity = dir * muck.speed
	muck.rotation = dir.angle()

	get_tree().current_scene.add_child(muck)


# =========================
# DAMAGE / DEATH
# =========================
func take_damage(amount):
	if is_dead:
		return

	currentHealth -= amount
	print(currentHealth)
	healthChanged.emit()

	if currentHealth <= 0:
		die()


func die():
	if is_dead:
		return

	is_dead = true

	# disconnect safely
	if conductor and conductor.beat.is_connected(_on_beat):
		conductor.beat.disconnect(_on_beat)

	animated_sprite.play("close")
	await animated_sprite.animation_finished
	animated_sprite.hide()
	
	explosion_sprite.show()
	explosion_sprite.play("explosion")
	await explosion_sprite.animation_finished

	defeated.emit()
	queue_free()
