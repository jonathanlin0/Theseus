extends Node2D


const STAIRS = preload("res://Bosses/stairs.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("fade")
	master_data._reset_all()
	master_data.level = 1
	master_data.start_time = OS.get_unix_time()
	
func _process(delta):
	# temporary, only for testing
	if Input.is_action_just_pressed("ui_n"):
		get_tree().change_scene("res://Levels/Level2.tscn")
