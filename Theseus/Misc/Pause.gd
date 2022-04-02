extends Control


var showing_controls = false


func _input(event):
	if event.is_action_pressed("ui_pause") or event.is_action_pressed("ui_cancel"):
		if showing_controls == false:
			pause()
	if event.is_action_pressed("ui_cancel") and showing_controls == true:
		showing_controls = false
		$Controls.visible = false

func pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state


func _on_Resume_pressed():
	pause()


func _on_Restart_pressed():
	pause()
	if master_data.is_multiplayer == false:
		get_tree().change_scene("res://Levels/" + get_tree().get_current_scene().name + ".tscn")
		master_data.health = master_data.max_health
		master_data.mana = master_data.max_mana
	if master_data.is_multiplayer == true:
		master_data.level = 0
		get_tree().change_scene("res://Misc/Multiplayer.tscn")
		master_data._reset_all()
		master_data._reset_all_p2()
	elif master_data.is_endless == true:
		master_data.level = 0
		get_tree().change_scene("res://Levels/Endless_Mode.tscn")
		master_data._reset_all()

func _on_Exit_pressed():
	pause()
	get_tree().change_scene("res://Menu/Title_Screen.tscn")


func _on_Controls_pressed():
	showing_controls = true
	$Controls.visible = true
