extends Node2D


func _process(delta):

	if Input.is_action_just_pressed("ui_n"):
		master_data.end_time = OS.get_unix_time()
		
		# only for testing
		get_tree().change_scene("res://Misc/Leaderboard.tscn")
