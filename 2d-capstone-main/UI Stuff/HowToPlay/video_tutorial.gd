extends Button

func _on_video_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://UI Stuff/HowToPlay/tutorial_video.tscn")


func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://UI Stuff/MainMenu.tscn")
