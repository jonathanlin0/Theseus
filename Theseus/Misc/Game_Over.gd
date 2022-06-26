extends Node2D

func _ready():
	$AnimationPlayer.play("fade")
	$AudioStreamPlayer.play()
	
	if master_data.previous_scene.find("Level") == -1:
		$Restart_button.disabled = true
		$Restart_button.visible = false

func _on_Menu_button_pressed():
	get_tree().change_scene("res://Menu/Title_Screen.tscn")


func _on_Restart_button_pressed():
	
	get_tree().change_scene("res://Levels/Level1.tscn")


func _on_AnimationPlayer_animation_finished(anim_name):
	$ColorRect.queue_free()
	$AnimationPlayer.queue_free()
