extends Node2D



func _ready():
	pass


#func _process(delta):
#	pass


func _on_Play_pressed():
	get_tree().change_scene("res://Levels/Level1.tscn")
