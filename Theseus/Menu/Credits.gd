extends Node2D


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://Menu/Title_Screen.tscn")
