class_name Bow
extends WeaponClass

@export var projectile_scene : PackedScene
@onready var bowSprite: Sprite2D = %BowSprite
@onready var drawnSprite: Sprite2D = %DrawnBowSprite

var direction : float = 1.0

func attack():
	if canAttack == false:
		return
	canAttack = false
	bowSprite.visible = false
	drawnSprite.visible = true
	await get_tree().create_timer(attackSpeed / 5.0 ).timeout
	drawnSprite.visible = false
	bowSprite.visible = true
	performAttack()
	await get_tree().create_timer(attackSpeed).timeout
	canAttack = true

func performAttack():
	var arrow = projectile_scene.instantiate()
	var dir = -1.0 if get_parent().scale.x < 0 else 1.0
	arrow.setup(damage, dir, attackRange)
	get_tree().current_scene.add_child(arrow)
	arrow.global_position = global_position
	arrow.z_index = 100
	$AudioStreamPlayer2D.play()
