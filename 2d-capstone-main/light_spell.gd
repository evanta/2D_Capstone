extends CharacterBody2D

@export var speed = 500
@export var damage = 10

func _ready():
	velocity = Vector2.RIGHT.rotated(global_rotation) * speed
	add_collision_exception_with(get_parent())

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta, false)
	
	if collision:
		var body = collision.get_collider()
		# 💥 Deal damage if possible
		if body:
			if body.has_method("take_damage"):
				body.take_damage(damage)
				queue_free()
				return

		velocity = velocity.bounce(collision.get_normal())
		rotation = velocity.angle()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
