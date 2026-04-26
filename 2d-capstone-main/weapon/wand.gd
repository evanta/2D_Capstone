extends Node2D

var owner_body: CharacterBody2D  # player reference
@export var SpellScene = preload("res://weapon/light_spell.tscn")

func shoot(damage):
	var spell = SpellScene.instantiate()
	spell.damage = damage
	var direction = get_parent().last_move_dir
	
	spell.global_position = $Muzzle.global_position
	spell.velocity = direction * spell.speed
	spell.rotation = direction.angle()

	
	#var dir = -1.0 if get_parent().scale.x < 0 else 1.0
	get_tree().current_scene.add_child(spell)
	
	
