extends Node

const PLAYER = preload("res://Character/Player.tscn")

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
	
	if player_positions.size() > 0:
		for given_player in player_positions.keys():
			if players_on_screen.keys().find(given_player) == -1:
				var new_player = PLAYER.instance()
				get_parent().add_child(new_player)
				new_player.position = player_positions[given_player]
				
				players_on_screen[given_player] = [new_player, player_positions[given_player]]
	
	for given_player in players_on_screen.keys():
		players_on_screen[given_player][0].global_position = player_positions[given_player]
	
	

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
	add_text(str(pos))

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
