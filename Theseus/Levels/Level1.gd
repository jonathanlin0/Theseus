extends Node2D


const STAIRS = preload("res://Bosses/stairs.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	master_data.health = 100
	master_data.mana = 100
	master_data.max_health = 100
	master_data.max_mana = 100
	master_data.ranged_multiplier = 1.0
	master_data.melee_multiplier = 1.0
	master_data.player_speed = 7000
	
	master_data.start_time = OS.get_unix_time()
	
func _process(delta):
	# temporary, only for testing
	if Input.is_action_just_pressed("ui_n"):
		get_tree().change_scene("res://Levels/Level2.tscn")
