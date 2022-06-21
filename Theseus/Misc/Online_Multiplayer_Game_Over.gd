extends ColorRect



func _ready():
	pass

func set_status(status):
	$Message.text = status


func _on_Play_Again_Button_pressed():
	Server.restart_online_multiplayer_game()
