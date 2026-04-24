extends Node2D

var owner_body: CharacterBody2D  # player reference
@export var SpellScene = preload("res://light_spell.tscn")

func _physics_process(delta):
	if owner_body == null:
		return

	# Position wand relative to player
	position = Vector2(9, 5)  # basic offset
	# Rotate toward mouse
	look_at(get_global_mouse_position())

func shoot():
	var spell = SpellScene.instantiate()
	
	var direction = (get_global_mouse_position() - $Muzzle.global_position).normalized()
	
	spell.global_position = $Muzzle.global_position
	spell.velocity = direction * spell.speed
	spell.rotation = direction.angle()
	
	get_tree().current_scene.add_child(spell)
