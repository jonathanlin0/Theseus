extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	master_data.health = 100
	master_data.mana = 100
	master_data.max_health = 100
	master_data.max_mana = 100
	master_data.ranged_multiplier = 1.0
	master_data.melee_multiplier = 1.0
	master_data.player_speed = 7000

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
