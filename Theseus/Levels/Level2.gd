extends Node2D

const STAIRS = preload("res://Bosses/stairs.tscn")

func _process(delta):
	
	# temporary, only for testing
	if Input.is_action_just_pressed("ui_n"):
		get_tree().change_scene("res://Levels/Level3.tscn")