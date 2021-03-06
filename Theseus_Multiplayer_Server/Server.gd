extends Node

const PLAYER = preload("res://Character/Player.tscn")
const FIREBALL = preload("res://Weapons/Fireball.tscn")

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100
var current_players = 0

var player_healths = {}
"""
Structure:
	
{
	player_id: health,
	player_id: health
}
"""

# holds all of the players' directions
var player_directions = {}
"""
Structure:
	
{
	player_user_id:"left"
}

"""

# holds all of the players' positions on the screen
var player_positions = {}
"""
structure:

{
	player_user_id:(2,4)
}
"""

# the dictionary holds all the current players on the screen
var players_on_screen = {}
"""
{
	player_user_id:[
		object,
		position
	]
}
"""


var fireballs = {}
"""
structure:
	
{
	player_user_id:{
		fireball_1_instance_id: {
			"position":(2,3),
			"vector":(2,3),
			"angle":pi
		}
	}
	player_user_id:{
		fireball_1_instance_id: {
			"position":(2,3),
			"vector":(2,3),
			"angle":pi
		}
	}
}
"""

var fireballs_on_screen = {}
"""
Structure:
	
{
	fireball_instance_id = {
		"object":object,
		"position"(2,34),
		"angle": pi
	}
}
"""

# used to see if the game is over
var game_over = false
# used to make sure the game over msg is only sent once
var sent_game_over_msg = false

var server_start_time = OS.get_unix_time()


# used to make sure packet count is only changed every 3 seconds to prevent too much processing
var last_changed_time = 0
# keeps the packet counter
var packets = {}
"""
Structure:
	
{
	OS.get_unix_time(): 32,
	OS.get_unix_time(): 4
}
"""

# the last recorded process time rate
var last_process_time = 0
# the time between each frame
var delta_var = 0.1


func add_text(text):
	var existing_text = $Console.text
	existing_text = text + "\n" + existing_text
	$Console.text = existing_text
	
func _ready():
	
	server_start_time = OS.get_unix_time()
	start_server()
	

func _process(delta):
	
	delta_var = delta
	
	# display how many concurrent players
	$Stats/Current_Players.text = "Concurrent Players: " + str(current_players)
	
	# display how many concurrent fireballs
	var fireball_cnt = 0
	for given_player_id in fireballs.keys():
		fireball_cnt += fireballs[given_player_id].size()
	$Stats/Fireball_Cnt.text = "Concurrent Fireballs: " + str(fireball_cnt)
	
	# udpate the packet count every 3 seconds
	if last_changed_time != OS.get_unix_time() and OS.get_unix_time() % 3 == 0:
		
		# erase packet counts past 10 seconds ago
		for given_time in packets.keys():
			if given_time <= (OS.get_unix_time() - 10):
				packets.erase(given_time)
			if given_time > (OS.get_unix_time() - 10):
				break
		
		last_changed_time = OS.get_unix_time()
		
		var total_packet_count = 0
		var total_packet_seconds = 0
		
		# average the packet count from the last 3 seconds, if they exist
		var valid_seconds = packets.keys()
		if valid_seconds.find(OS.get_unix_time() - 1) != -1:
			total_packet_seconds += 1
			total_packet_count += packets[OS.get_unix_time() - 1]
		if valid_seconds.find(OS.get_unix_time() - 2) != -1:
			total_packet_seconds += 1
			total_packet_count += packets[OS.get_unix_time() - 2]
		if valid_seconds.find(OS.get_unix_time() - 3) != -1:
			total_packet_seconds += 1
			total_packet_count += packets[OS.get_unix_time() - 3]
		
		if total_packet_seconds != 0:
			$Stats/Packet_Cnt.text = "Packets: " + str(total_packet_count / total_packet_seconds) + " per second"
	
	for player_id in player_healths.keys():
		if player_healths[player_id] <= 0:
			game_over = true
	

	if game_over == true:
		$CanvasLayer/ColorRect.visible = true
		if OS.get_unix_time() % 4 == 0:
			$CanvasLayer/ColorRect/Game_Over_Text_2.text = "Waiting for players' response"
		if OS.get_unix_time() % 4 == 1:
			$CanvasLayer/ColorRect/Game_Over_Text_2.text = "Waiting for players' response."
		if OS.get_unix_time() % 4 == 2:
			$CanvasLayer/ColorRect/Game_Over_Text_2.text = "Waiting for players' response.."
		if OS.get_unix_time() % 4 == 3:
			$CanvasLayer/ColorRect/Game_Over_Text_2.text = "Waiting for players' response..."
	
	# this ends the game
	if game_over == true and sent_game_over_msg == false and player_healths.size() > 0:

		# see who has the least health left
		var loser_id = player_healths.keys()[0]
		var loser_health = player_healths[player_healths.keys()[0]]
		
		for player_id in player_healths.keys():
			if player_healths[player_id] < loser_health:
				loser_id = player_id
				loser_health = player_healths[player_id]
		for player_id in player_healths.keys():
			if player_id == loser_id:
				rpc_id(player_id, "game_over", "lose")
			if player_id != loser_id:
				rpc_id(player_id, "game_over", "win")
		
		sent_game_over_msg = true
	
	if game_over == false:
		
		$CanvasLayer/ColorRect.visible = false
		
		
		
		
		# controls showing the player on screen
		if player_positions.size() > 0:
			for given_player in player_positions.keys():
				if players_on_screen.keys().find(given_player) == -1:
					var new_player = PLAYER.instance()
					get_parent().add_child(new_player)
					new_player.position = player_positions[given_player]
					new_player.user_id = given_player
					new_player.get_node("AnimatedSprite").play("idle_down")
					
					players_on_screen[given_player] = [new_player, player_positions[given_player]]
		
		var all_player_instance_ids = []
		for given_player in player_positions.keys():
			all_player_instance_ids.append(given_player)

		# remove all the clients that are not being sent by the clients anymore
		for player_id in players_on_screen.keys():
			if all_player_instance_ids.find(player_id) == -1:
				players_on_screen[player_id][0].queue_free()
				players_on_screen.erase(player_id)
		
		for given_player in players_on_screen.keys():
			players_on_screen[given_player][0].global_position = player_positions[given_player]
			if player_directions[given_player] == "down" or player_directions[given_player] == "up":
				if player_directions[given_player] == "down":
					players_on_screen[given_player][0].get_node("AnimatedSprite").play("idle_down")
				elif player_directions[given_player] == "up":
					players_on_screen[given_player][0].get_node("AnimatedSprite").play("idle_up")
			else:
				if player_directions[given_player] == "left":
					players_on_screen[given_player][0].get_node("AnimatedSprite").play("idle_left")
				elif player_directions[given_player] == "right":
					players_on_screen[given_player][0].get_node("AnimatedSprite").play("idle_right")
			
		
		
		# shows the fireballs on screen
		for given_player in fireballs.keys():
			for fireball_instance_id in fireballs[given_player].keys():
				if fireballs_on_screen.keys().find(fireball_instance_id) == -1:
					var new_fireball = FIREBALL.instance()
					add_child(new_fireball)
					new_fireball.position = fireballs[given_player][fireball_instance_id]["position"]
					new_fireball.player_id = given_player
					new_fireball.rotate(fireballs[given_player][fireball_instance_id]["angle"])
					
					
					fireballs_on_screen[fireball_instance_id] = {
						"object":new_fireball,
						"position":fireballs[given_player][fireball_instance_id]["position"],
						"angle":fireballs[given_player][fireball_instance_id]["angle"]
					}
		
		
		var all_fireball_instance_ids = []
		for given_player in fireballs.keys():
			for fireball_id in fireballs[given_player].keys():
				all_fireball_instance_ids.append(fireball_id)

		# remove all the fireballs that are not being sent by the clients anymore
		for fireball_instance_id in fireballs_on_screen.keys():
				if all_fireball_instance_ids.find(fireball_instance_id) == -1:
					var wr = weakref(fireballs_on_screen[fireball_instance_id]["object"])
					if wr.get_ref():
						fireballs_on_screen[fireball_instance_id]["object"].queue_free()
						fireballs_on_screen.erase(fireball_instance_id)
		
		# update fireball positions
		for fireball_instance_id in fireballs_on_screen.keys():
			var wr = weakref(fireballs_on_screen[fireball_instance_id]["object"])
			if wr.get_ref():
				var temp_player_id = fireballs_on_screen[fireball_instance_id]["object"].player_id
				
				fireballs_on_screen[fireball_instance_id]["object"].position = fireballs[temp_player_id][fireball_instance_id]["position"]
		
		# update players' health bars
		if players_on_screen.size() > 0 and player_healths.size() > 0:
			for player_id in players_on_screen.keys():
				players_on_screen[player_id][0].get_node("Health_Bar").setMax(100)
				players_on_screen[player_id][0].get_node("Health_Bar").setValue(player_healths[player_id])
	

func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	add_text("Server started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")
	

func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")
	add_text("User " + str(player_id) + " Connected")
	current_players += 1
	
	if player_healths.keys().find(player_id) == -1:
		player_healths[player_id] = 100

func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")
	add_text("User " + str(player_id) + " Disconnected")
	current_players -= 1
	
	player_positions.erase(player_id)
	player_directions.erase(player_id)
	player_healths.erase(player_id)
	

func add_packet():
	var cur_time = OS.get_unix_time()
	if packets.keys().find(cur_time) != -1:
		var temp = packets[cur_time]
		temp += 1
		packets[cur_time] = temp
	if packets.keys().find(cur_time) == -1:
		packets[cur_time] = 1

remote func send_position(pos, dir):
	add_packet()
	
	var player_id = get_tree().get_rpc_sender_id()
	player_positions[player_id] = pos
	player_directions[player_id] = dir

remote func send_fireballs(fireball_dict):
	add_packet()
	
	var player_id = get_tree().get_rpc_sender_id()
	fireballs[player_id] = fireball_dict

remote func fetch_fireballs():
	add_packet()
	
	var player_id = get_tree().get_rpc_sender_id()
	var fireballs_copy = {}
	for given_player_id in fireballs.keys():
		if given_player_id != player_id:
			fireballs_copy[given_player_id] = fireballs[given_player_id]
	
	rpc_id(player_id, "return_fireballs", fireballs_copy)

remote func fetch_test_data():
	add_packet()
	
	var player_id = get_tree().get_rpc_sender_id()
	var return_value = "test successful"
	
	rpc_id(player_id, "return_test_data", return_value)
	add_text("Sent Test Data to Client")

remote func fetch_ping(start_time):
	add_packet()
	
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_ping", start_time)

remote func fetch_players():
	add_packet()
	
	var player_id = get_tree().get_rpc_sender_id()
	
	# copy the player_positions dictionary
	var temp_player_positions = {}
	for given_player_id in player_positions:
		if given_player_id != player_id:
			temp_player_positions[given_player_id] = player_positions[given_player_id]
	
	# copy the player_directions dictionary
	var temp_player_directions = {}
	for given_player_id in player_directions:
		if given_player_id != player_id:
			temp_player_directions[given_player_id] = player_directions[given_player_id]
	
	rpc_id(player_id, "return_players", temp_player_positions, temp_player_directions)

remote func fetch_healths():
	add_packet()
	
	var player_id = get_tree().get_rpc_sender_id()
	
	# copy the player_healths dictionary
	var temp_player_healths = {}
	for given_player_id in player_healths:
		if given_player_id != player_id:
			temp_player_healths[given_player_id] = player_healths[given_player_id]
	

	rpc_id(player_id, "return_healths", temp_player_healths)

remote func fetch_my_health():
	add_packet()
	
	var player_id = get_tree().get_rpc_sender_id()
	
	rpc_id(player_id, "return_my_health", player_healths[player_id])

remote func fetch_connection():
	add_packet()
	
	var player_id = get_tree().get_rpc_sender_id()
	
	rpc_id(player_id, "return_connection")
	
remote func restart_online_multiplayer_game():
	for player_id in player_healths.keys():
		player_healths[player_id] = 100
	
	for player_id in fireballs.keys():
		for fireball_id in fireballs[player_id].keys():
			fireballs[player_id].erase(fireball_id)
	
	game_over = false
	sent_game_over_msg = false
	
	for player_id in player_positions.keys():
		rpc_id(player_id, "game_over", "")


func _on_Process_Update_timeout():
	
	
	var current_process_time = 1/delta_var
	
	if (current_process_time - last_process_time) > 1 or (last_process_time - current_process_time) > 1:
		$Stats/Process_Cnt.text = "Processes: " + str(round(current_process_time)) + " per second"
	
	last_process_time = current_process_time
