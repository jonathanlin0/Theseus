extends Node2D

const STAIRS = preload("res://Bosses/stairs.tscn")
var cursor = load("res://Misc/Sprites/cursor_cross.png")

func _ready():
	Input.set_custom_mouse_cursor(cursor)
	master_data.level = 2
	master_data.music = "stage"
	master_data.previous_scene = "Level2"

func _process(delta):
	
	if Input.is_action_just_pressed("ui_n"):
		get_tree().change_scene("res://Levels/Level3.tscn")
