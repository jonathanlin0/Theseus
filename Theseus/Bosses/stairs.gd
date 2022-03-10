extends Area2D



var dest = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _set_destination(target):
	dest = target


func _on_stairs_body_entered(body):
	
	if body.name.find("Player") != -1:
		if (dest == "stage_one"):
			get_tree().change_scene("res://Levels/Level1.tscn")
		if (dest == "stage_two"):
			get_tree().change_scene("res://Levels/Level2.tscn")
		if (dest == "stage_three"):
			get_tree().change_scene("res://Levels/Level3.tscn")
