extends Area2D
var damage : float = 0.0
var speed : float = 900.0
var direction : float = 1.0
var lifetime : float = 1.0
var hasHit = false

func setup(dmg : float, dir : float, rng : float):
	damage = dmg
	direction = dir
	lifetime = rng
	if direction < 0:
		scale.x = -1

func _ready():
	add_to_group("projectile")
	body_entered.connect(onBodyEntered)
	area_entered.connect(onAreaEntered)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta):
	position.x += speed * direction * delta

func onBodyEntered(body):
	if hasHit:
		return
	if body.is_in_group("player"):
		return
	hasHit = true
	
	var overlapping = get_overlapping_areas()
	for area in overlapping:
		if area.name == "Headshot":
			area.get_parent().onStyleKill("HEADSHOT!")
			queue_free()
			return
	
	if body.has_method("takeDamage"):
		body.takeDamage(damage)
	queue_free()

func onAreaEntered(area):
	if hasHit:
		return
	if area.is_in_group("player"):
		return
	hasHit = true
	
	if area.name == "Headshot":
		area.get_parent().onStyleKill("HEADSHOT!")
	elif area.name == "Hitbox":
		var overlapping = get_overlapping_areas()
		for a in overlapping:
			if a.name == "Headshot":
				a.get_parent().onStyleKill("HEADSHOT!")
				queue_free()
				return
		area.get_parent().takeDamage(damage)
	
	queue_free()
