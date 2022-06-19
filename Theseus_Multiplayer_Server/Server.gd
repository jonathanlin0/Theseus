extends Node

const PLAYER = preload("res://Character/Player.tscn")
const FIREBALL = preload("res://Weapons/Fireball.tscn")

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100
var current_players = 0

var player_positions = {}
"""
structure:

{
	player_user_id:(2,4)
}
"""

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
		"position"(2,34)
	}
}
"""


func add_text(text):
	var existing_text = $Console.text
	existing_text = text + "\n" + existing_text
	$Console.text = existing_text
	
func _ready():
	
	start_server()
	

func _process(delta):
	$Stats/Current_Players.text = "Concurrent Players: " + str(current_players)
	
	var fireball_cnt = 0
	for given_player_id in fireballs.keys():
		fireball_cnt += fireballs[given_player_id].size()
	$Stats/Fireball_Cnt.text = "Concurrent Fireballs: " + str(fireball_cnt)
	
	# controls showing the player on screen
	if player_positions.size() > 0:
		for given_player in player_positions.keys():
			if players_on_screen.keys().find(given_player) == -1:
				var new_player = PLAYER.instance()
				get_parent().add_child(new_player)
				new_player.position = player_positions[given_player]
				
				players_on_screen[given_player] = [new_player, player_positions[given_player]]
	
	for given_player in players_on_screen.keys():
		players_on_screen[given_player][0].global_position = player_positions[given_player]
	
	
	# shows the fireballs on screen
	for given_player in fireballs.keys():
		for fireball_instance_id in fireballs[given_player].keys():
			if fireballs_on_screen.keys().find(fireball_instance_id) == -1:
				var new_fireball = FIREBALL.instance()
				get_parent().add_child(new_fireball)
				new_fireball.position = fireballs[given_player][fireball_instance_id]["position"]
				new_fireball.player_id = given_player
				new_fireball.rotate(fireballs[given_player][fireball_instance_id]["angle"])
				
				
				fireballs_on_screen[fireball_instance_id] = {
					"object":new_fireball,
					"position":fireballs[given_player][fireball_instance_id]["position"]
				}
	
	
	var all_fireball_instance_ids = []
	for given_player in fireballs.keys():
		for fireball_id in fireballs[given_player].keys():
			all_fireball_instance_ids.append(fireball_id)

	# remove all the fireballs that are not being sent by the clients anymore
	for fireball_instance_id in fireballs_on_screen.keys():
		if all_fireball_instance_ids.find(fireball_instance_id) == -1:
			fireballs_on_screen[fireball_instance_id]["object"].queue_free()
			fireballs_on_screen.erase(fireball_instance_id)
	
	# update fireball positions
	for fireball_instance_id in fireballs_on_screen.keys():
		var temp_player_id = fireballs_on_screen[fireball_instance_id]["object"].player_id
		
		fireballs_on_screen[fireball_instance_id]["object"].position = fireballs[temp_player_id][fireball_instance_id]["position"]
	
	"""
	for given_player in fireballs.keys():
		for fireball_instance_id in fireballs[given_player].keys():
			if fireballs[given_player][fireball_instance_id]["object"] == null:
				var new_fireball = FIREBALL.instance()
				get_parent().add_child(new_fireball)
				new_fireball.position = fireballs[given_player][fireball_instance_id]["position"]
				print("hi")
			else:
				fireballs[given_player][fireball_instance_id]["object"].global_position = fireballs[given_player][fireball_instance_id]["position"]
	"""

func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")
	

func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")
	add_text("User " + str(player_id) + " Connected")
	current_players += 1

func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")
	add_text("User " + str(player_id) + " Disconnected")
	current_players -= 1
	
	player_positions.erase(player_id)
	players_on_screen[player_id][0].queue_free()
	players_on_screen.erase(player_id)
	

remote func send_position(pos):
	var player_id = get_tree().get_rpc_sender_id()
	player_positions[player_id] = pos

remote func send_fireballs(fireball_dict):
	var player_id = get_tree().get_rpc_sender_id()
	fireballs[player_id] = fireball_dict

remote func fetch_fireballs():
	var player_id = get_tree().get_rpc_sender_id()
	var fireballs_copy = fireballs
	fireballs_copy.erase(player_id)
	
	var return_value = fireballs_copy
	
	rpc_id(player_id, "return_test_data", return_value)
	add_text("Sent Fireball Data")

remote func fetch_test_data():
	var player_id = get_tree().get_rpc_sender_id()
	var return_value = "test successful"
	
	rpc_id(player_id, "return_test_data", return_value)
	add_text("Sent Test Data")

remote func fetch_ping(start_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_ping", start_time)
