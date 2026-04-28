extends Node2D

var target_position: Vector2
var move_speed: float = 300.0

func _process(delta):
	position = position.move_toward(target_position, move_speed * delta)

	if position.distance_to(target_position) < 5:
		queue_free()
