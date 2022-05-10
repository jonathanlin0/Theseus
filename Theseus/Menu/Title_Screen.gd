extends Node2D



func _ready():
	$Music.play()
	master_data.previous_scene = "title"
	master_data.level = 0
	master_data.is_multiplayer = false
	master_data.is_endless = false
	master_data.endless_health_multiplier = 1.0

#func _process(delta):
#	pass


func _on_Play_pressed():
	$Play/play.play()
	$Play/Timer.start()


func _on_Controls_pressed():
	get_tree().change_scene("res://Misc/single_controls.tscn")


func _on_TextureButton_pressed():
	pass # Replace with function body.


func _on_Exit_pressed():
	get_tree().quit()


func _on_Credits_pressed():
	get_tree().change_scene("res://Menu/Credits.tscn")


func _on_Leaderboard_pressed():
	get_tree().change_scene("res://Misc/Leaderboard.tscn")


func _on_Multiplayer_pressed():
	$Multiplayer/multiplayer.play()
	$Multiplayer/multiTimer.start()


func _on_Timer_timeout():
	get_tree().change_scene("res://Misc/intro.tscn")



func _on_controls_finished():
	get_tree().change_scene("res://Misc/single_controls.tscn")


func _on_leaderboard_finished():
	get_tree().change_scene("res://Misc/Leaderboard.tscn")


func _on_exit_finished():
	pass # Replace with function body.


func _on_multiplayer_finished():
	pass


func _on_credits_finished():
	get_tree().change_scene("res://Menu/Credits.tscn")


func _on_multiTimer_timeout():
	get_tree().change_scene("res://Misc/Multiplayer.tscn")
