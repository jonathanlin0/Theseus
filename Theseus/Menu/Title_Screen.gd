extends Node2D



func _ready():
	master_data.previous_scene = "title"
	master_data.level = 1
	master_data.is_multiplayer = false


#func _process(delta):
#	pass


func _on_Play_pressed():
	get_tree().change_scene("res://Misc/intro.tscn")


func _on_Controls_pressed():
	get_tree().change_scene("res://Misc/single_controls.tscn")


func _on_TextureButton_pressed():
	pass # Replace with function body.


func _on_Exit_pressed():
	pass # Replace with function body.


func _on_Credits_pressed():
	get_tree().change_scene("res://Menu/Credits.tscn")


func _on_Leaderboard_pressed():
	get_tree().change_scene("res://Misc/Leaderboard.tscn")


func _on_Multiplayer_pressed():
	get_tree().change_scene("res://Misc/Multiplayer.tscn")
