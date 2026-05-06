extends StaticBody2D

signal defeated

@export var SpellScene = preload("res://purple_muck.tscn")
@export var damage: float = 10
@export var maxHealth: float = 100
@export var currentHealth: float = 100

@onready var animated_sprite = $BossSprite
@onready var explosion_sprite = $ExplosionSprite
@onready var shooter = $Shooter
@onready var boss_area = get_parent()
@onready var conductor = get_parent().get_node("Conductor")

var player = null
var player_in_area := false
var is_dead := false
var beat_counter := 0

func _ready():
	currentHealth = maxHealth

	boss_area.body_entered.connect(_on_body_entered)
	boss_area.body_exited.connect(_on_body_exited)

	if conductor:
		conductor.beat.connect(_on_beat)

	explosion_sprite.hide()
	animated_sprite.play("close")


# =========================
# PLAYER DETECTION
# =========================
func _on_body_entered(body):
	if body.is_in_group("player") and not is_dead:
		player = body
		player_in_area = true

		animated_sprite.play("open")
		await animated_sprite.animation_finished

		if player_in_area:
			animated_sprite.play("idle")


func _on_body_exited(body):
	if body == player:
		player_in_area = false
		player = null
		animated_sprite.play("close")


# =========================
# BEAT SHOOTING (every 8 beats)
# =========================
func _on_beat(_beat):
	if is_dead or not player_in_area:
		return

	beat_counter += 1
	if beat_counter >= 8:
		beat_counter = 0
		shoot()


func shoot():
	if player == null:
		return

	var muck = SpellScene.instantiate()
	muck.damage = damage

	var dir = (player.global_position - shooter.global_position).normalized()

	muck.global_position = shooter.global_position
	muck.velocity = dir * muck.speed
	muck.rotation = dir.angle()

	get_parent().add_child(muck)


# =========================
# DAMAGE / DEATH
# =========================
func take_damage(amount):
	if is_dead:
		return

	currentHealth -= amount

	if currentHealth <= 0:
		die()


func die():
	if is_dead:
		return

	is_dead = true

	if conductor:
		conductor.beat.disconnect(_on_beat)

	animated_sprite.play("close")
	await animated_sprite.animation_finished

	explosion_sprite.show()
	explosion_sprite.play("explode")
	await explosion_sprite.animation_finished

	# IMPORTANT: notify BossArea
	defeated.emit()

	queue_free()
