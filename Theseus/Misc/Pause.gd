extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _input(event):
	if event.is_action_pressed("ui_pause") or event.is_action_pressed("ui_cancel"):
		pause()

func pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state


func _on_Resume_pressed():
	pause()


func _on_Restart_pressed():
	pause()
	get_tree().change_scene("res://Levels/" + get_tree().get_current_scene().name + ".tscn")

func _on_Exit_pressed():
	pause()
	get_tree().change_scene("res://Misc/Title_Screen.tscn")
