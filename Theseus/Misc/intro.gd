extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	master_data.previous_scene = "intro"
	master_data.level = 1
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		_on_VideoPlayer_finished()


func _on_VideoPlayer_finished():
	get_tree().change_scene("res://Misc/single_controls.tscn")


func _on_Timer_timeout():
	$Sprite.visible = false
