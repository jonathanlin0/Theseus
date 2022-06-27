extends Node2D


func _ready():
	pass


func _on_Online_Button_pressed():
	get_tree().change_scene("res://Misc/Online_Multiplayer_Loading_Screen.tscn")


func _on_Offline_Button_pressed():
	get_tree().change_scene("res://Misc/Multiplayer.tscn")
