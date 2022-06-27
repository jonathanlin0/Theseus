extends Node2D

var cursor = load("res://Misc/Sprites/cursor_cross.png")

func _ready():
	Input.set_custom_mouse_cursor(cursor)
	master_data._reset_all()
	master_data.level = 0
