extends Node2D

func _ready():
	$AudioStreamPlayer.play()

func _on_Menu_button_pressed():
	get_tree().change_scene("res://Menu/Title_Screen.tscn")


func _on_Restart_button_pressed():
	get_tree().change_scene("res://Levels/Level1.tscn")
