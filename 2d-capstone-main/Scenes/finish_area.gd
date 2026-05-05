extends Area2D
@export var nextlevel = "res://Levels/LevelTemplate.tscn"

@onready var rootlevel = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and rootlevel.finishcheck() == true:
		print("player is ready to move to next level")
		get_tree().change_scene_to_file(nextlevel)
	else:
		print("player must defeat all corrup areas")
