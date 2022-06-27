extends Camera2D


var finish = false

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	if master_data.is_multiplayer or get_parent().get_parent().name.find("Endless_Mode") != -1 or get_parent().get_parent().name.find("Multiplayer") != -1:
		$stagetitles.stop()
		visible = false
	elif master_data.level == 1:
		visible = true
		finish = false
		$stagetitles.play("stage1")
		$Timer.start()
	elif master_data.level == 2:
		visible = true
		finish = false
		$stagetitles.play("stage2")
		$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_stagetitles_animation_finished():
	if finish:
		$stagetitles.play("blank")


func _on_Timer_timeout():
	if !finish:
		if master_data.level == 1:
			$stagetitles.play("stage1fade")
			finish = true
		elif master_data.level == 2:
			$stagetitles.play("stage2fade")
			finish = true
