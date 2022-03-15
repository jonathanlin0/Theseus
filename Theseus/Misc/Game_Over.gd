extends Node2D

func _ready():
	$AnimationPlayer.play("fade")
	$AudioStreamPlayer.play()

func _on_Menu_button_pressed():
	get_tree().change_scene("res://Menu/Title_Screen.tscn")


func _on_Restart_button_pressed():
	get_tree().change_scene("res://Levels/Level1.tscn")


func _on_AnimationPlayer_animation_finished(anim_name):
	$ColorRect.queue_free()
	$AnimationPlayer.queue_free()
