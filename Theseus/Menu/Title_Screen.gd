extends Node2D



func _ready():
	master_data.previous_scene = "title"


#func _process(delta):
#	pass


func _on_Play_pressed():
	get_tree().change_scene("res://Misc/intro.tscn")


func _on_Controls_pressed():
	get_tree().change_scene("res://Misc/single_controls.tscn")


func _on_TextureButton_pressed():
	pass # Replace with function body.


func _on_Exit_pressed():
	pass # Replace with function body.


func _on_Credits_pressed():
	get_tree().change_scene("res://Menu/Credits.tscn")
