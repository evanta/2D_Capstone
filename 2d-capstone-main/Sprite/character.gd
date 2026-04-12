extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@onready var camera_2d: Camera2D = $Camera2D
@export var cameraZoom : float = 1.1

const speed = 5
var virtmovement = false

func _ready():
	print("start")	
	camera_2d.zoom = Vector2(cameraZoom, cameraZoom)

	
func _process(delta):
	#movement 
	if Input.is_action_pressed("ui_right"):
		position.x += delta + speed
	if Input.is_action_pressed("ui_left"):
		position.x -= delta + speed
		
	if Input.is_action_pressed("ui_up"):
		position.y -= delta + speed
		virtmovement = true
	elif Input.is_action_pressed("ui_down"):
		position.y += delta + speed
		virtmovement = true
	else: 
		virtmovement = false
		
	#animation
	var dir := 0
	if Input.is_action_pressed("ui_right"):
		dir = 1
	elif Input.is_action_pressed("ui_left"):
		dir = -1
	
	if virtmovement == true:
		anim.play("jump")
	elif dir != 0:
		anim.flip_h = (dir < 0)
		if anim.animation != "jump":
			anim.play("jump")
	else:
		if anim.animation != "idle":
			anim.play("idle")
