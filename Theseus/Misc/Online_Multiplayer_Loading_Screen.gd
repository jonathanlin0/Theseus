extends Node2D

func _ready():
	$Loading_Text.text = "Loading Online Multiplayer"
	
	Server.initial_connect_to_server()
	Server.fetch_connection()
	Server.fetch_players()
	Server.fetch_healths()



func _on_Timer_1_timeout():
	$Loading_Text.text = "Loading Online Multiplayer."
	Server.fetch_players()


func _on_Timer_2_timeout():
	$Loading_Text.text = "Loading Online Multiplayer.."
	Server.fetch_players()



func _on_Timer_3_timeout():
	$Loading_Text.text = "Loading Online Multiplayer..."
	Server.fetch_players()


func _on_Timer_4_timeout():
	
	# 0 is the default spawn position
	# 1 to 4 are the 4 quadrant spawning locations
	var avaliable_quads = [0, 1, 2, 3, 4]
	
	for given_player in master_data.online_multiplayer_players.keys():
		if master_data.online_multiplayer_players[given_player].x > 240 and master_data.online_multiplayer_players[given_player].x < 480:
			if master_data.online_multiplayer_players[given_player].y > 0 and master_data.online_multiplayer_players[given_player].y < 135:
				avaliable_quads.erase(1)
		if master_data.online_multiplayer_players[given_player].x > 0 and master_data.online_multiplayer_players[given_player].x < 240:
			if master_data.online_multiplayer_players[given_player].y > 0 and master_data.online_multiplayer_players[given_player].y < 135:
				avaliable_quads.erase(2)
		if master_data.online_multiplayer_players[given_player].x > 0 and master_data.online_multiplayer_players[given_player].x < 240:
			if master_data.online_multiplayer_players[given_player].y > 135 and master_data.online_multiplayer_players[given_player].y < 270:
				avaliable_quads.erase(3)
		if master_data.online_multiplayer_players[given_player].x > 240 and master_data.online_multiplayer_players[given_player].x < 480:
			if master_data.online_multiplayer_players[given_player].y > 135 and master_data.online_multiplayer_players[given_player].y < 270:
				avaliable_quads.erase(4)
	
	if avaliable_quads.size() <= 0:
		master_data.online_multiplayer_spawn_quadrant = 0
	if avaliable_quads.size() > 0:
		var rand_quad = avaliable_quads[randi() % avaliable_quads.size()]
		master_data.online_multiplayer_spawn_quadrant = rand_quad
	
	get_tree().change_scene("res://Levels/Online_Multiplayer.tscn")
