extends Node2D


func _ready():
	pass


func _on_Online_Button_pressed():
	get_tree().change_scene("res://Levels/Online_Multiplayer.tscn")


func _on_Offline_Button_pressed():
	get_tree().change_scene("res://Misc/Multiplayer.tscn")
