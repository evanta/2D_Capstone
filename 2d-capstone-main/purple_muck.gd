extends Area2D

var fired_by = null
var damage := 10
var speed := 50
var velocity := Vector2.ZERO


func _ready():
	body_entered.connect(_on_body_entered)


func _physics_process(delta):
	global_position += velocity * delta


func _on_body_entered(body):
	# ignore whoever fired it (boss or anything else)
	if body == fired_by:
		return

	# ONLY damage player
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

		queue_free()
		return

	# ignore everything else (enemies, bosses, walls, etc.)
	return
