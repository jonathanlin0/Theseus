extends Node2D

var cursor = load("res://Misc/Sprites/cursor_cross.png")

const STAIRS = preload("res://Bosses/stairs.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(cursor)
	$AnimationPlayer.play("fade")
	$spawn.play()
	master_data._reset_all()
	master_data.level = 1
	master_data.start_time = OS.get_unix_time()
	master_data.music = "stage"
	master_data.previous_scene = "Level1"
	
func _process(delta):
	# temporary, only for testing
	if Input.is_action_just_pressed("ui_n"):
		get_tree().change_scene("res://Levels/Level2.tscn")
