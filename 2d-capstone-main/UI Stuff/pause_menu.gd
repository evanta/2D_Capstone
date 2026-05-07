extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # menu still processes while paused
	hide()
	
# ===== Pause / Resume =====
func pause():
	get_tree().paused = true
	show()

func resume():
	get_tree().paused = false
	hide()

# Called by submenus to show pause menu again
func show_pause_menu():
	show()

func _unhandled_input(event):
	if event.is_action_pressed("Pause"):
		if not is_visible():  # only toggle pause if menu is hidden
			if get_tree().paused:
				resume()
			else:
				pause()
				
# ===== Button callbacks =====
func _on_resume_pressed() -> void:
	resume()




func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()




func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://UI Stuff/MainMenu.tscn")
