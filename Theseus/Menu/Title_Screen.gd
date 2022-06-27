extends Node2D

var cursor = load("res://Misc/Sprites/cursor.png")

var selection = false
var last_pressed_button = ""

func _ready():
	selection = false
	$Music.play()
	Input.set_custom_mouse_cursor(cursor)
	master_data.previous_scene = "title"
	master_data.level = 0
	master_data.is_multiplayer = false
	master_data.is_endless = false
	master_data.endless_health_multiplier = 1.0
	
	Server.connect_to_server()
	Server.fetch_connection()

#func _process(delta):
#	pass


func _on_Play_pressed():
	if selection and last_pressed_button == "play":
		_on_Timer_timeout()
	if !selection:
		last_pressed_button = "play"
		var value = load("res://Menu/Sprites/menu_play_click.png")
		$Play/play.play()
		$Play/Timer.start()
		$Play.set_normal_texture(value)
		selection = true
	


func _on_Controls_pressed():
	get_tree().change_scene("res://Misc/single_controls.tscn")


func _on_Exit_pressed():
	get_tree().quit()


func _on_Credits_pressed():
	get_tree().change_scene("res://Menu/Credits.tscn")


func _on_Leaderboard_pressed():
	get_tree().change_scene("res://Misc/Leaderboard.tscn")


func _on_Multiplayer_pressed():
	if selection and last_pressed_button == "multiplayer":
		_on_multiTimer_timeout()
	if !selection:
		last_pressed_button = "multiplayer"
		var value = load("res://Menu/Sprites/menu_multiplayer_click.png")
		$Multiplayer.set_normal_texture(value)
		$Multiplayer/multiplayer.play()
		$Multiplayer/multiTimer.start()
		selection = true


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
	get_tree().change_scene("res://Menu/Multiplayer_Selection.tscn")


func _on_Endless_pressed():
	if selection and last_pressed_button == "endless":
		_on_endlessTimer_timeout()
	if !selection:
		last_pressed_button = "endless"
		var value = load("res://Menu/Sprites/menu_endless_click.png")
		$Endless/endless.play()
		$Endless/endlessTimer.start()
		$Endless.set_normal_texture(value)
		selection = true


func _on_endless_finished():
	pass # Replace with function body.


func _on_endlessTimer_timeout():
	get_tree().change_scene("res://Levels/Endless_Mode.tscn")
