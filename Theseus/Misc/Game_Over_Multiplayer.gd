extends Node2D

func _ready():
	$Player_x_won.text = "Player " + str(master_data.multiplayer_winner) + " won!"
	$AudioStreamPlayer.play()


func _on_Menu_Button_pressed():
	get_tree().change_scene("res://Menu/Title_Screen.tscn")
	

func _on_Restart_Button_pressed():
	master_data._reset_all()
	master_data._reset_all_p2()
	get_tree().change_scene("res://Misc/Multiplayer.tscn")
