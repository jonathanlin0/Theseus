extends Area2D

var activated = false

func _on_2x_Speed_body_entered(body):
	if body.name.find("Player") != -1 and activated == false:
		master_data.player_speed = master_data.player_speed * 2
		activated = true
		$Timer.start()
		self.visible = false


func _on_Timer_timeout():
	master_data.player_speed = master_data.player_speed / 2
	queue_free()
