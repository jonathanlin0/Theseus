extends Node

var network = NetworkedMultiplayerENet.new()
# the ip of 127.0.0.1 is local IP, so do not need VPS or another hosting platform to run the multiplayer game.
# in other words, can develop on a single desktop computer for free
# change the "ip" variable to the IP of the VPS if you want to run the server on a VPS

# local IP
var ip = "127.0.0.1"

# hao's ip
#var ip = "10.0.0.33"
var port = 1909

func _ready():
	initial_connect_to_server()
	

#func _process(delta):
#	pass

# this function is used to test the sending of data between the client and server
func fetch_test_data():
	# rpc() calls every peer on the network
	# rpc_id() allows you to call a specific peer on the network
	# rpc and rpc_id communicates w server and waits for a response from them, latency for client to wait for response from server. ensures that server received signal and sent back another one
	# rpc_unreliable and rpc_unreliable_id basically sends a crazy high number of packets and does not care if the server receives it. but sending like 60 packets a second, a considerable amount is bound to be received
	# rpc would be used for smt like opening an important loot crate
	# rpc_unreliable would be used for smt like sending player positions
	# 0 is everybody
	# 1 is the server
	# any other number is the specific peer you want to connect to
	rpc_id(1, "fetch_test_data")

func fetch_connection():
	rpc_id(1, "fetch_connection")

func send_position(pos, direction):
	rpc_unreliable_id(1, "send_position", pos, direction)
	
func send_fireballs(fireballs):
	rpc_unreliable_id(1, "send_fireballs", fireballs)
	
func fetch_ping(start_time):
	rpc_id(1, "fetch_ping", start_time)

func fetch_players():
	rpc_id(1, "fetch_players")

func fetch_fireballs():
	rpc_id(1, "fetch_fireballs")

func fetch_healths():
	rpc_id(1, "fetch_healths")

func fetch_my_health():
	rpc_id(1, "fetch_my_health")

func restart_online_multiplayer_game():
	rpc_id(1, "restart_online_multiplayer_game")


remote func return_test_data(test_val):
	# could do something with the returned test data here
	pass

remote func return_connection():
	master_data.online_multiplayer_is_connected = true

remote func return_fireballs(fireballs_input):
	master_data.online_multiplayer_fireballs = fireballs_input

remote func return_ping(start_time):
	master_data.online_multiplayer_ping = OS.get_ticks_msec() - start_time

remote func return_players(players, dir):
	master_data.online_multiplayer_players = players
	master_data.online_multiplayer_players_directions = dir

remote func return_healths(healths):
	master_data.online_multiplayer_players_healths = healths
	
remote func return_my_health(health):
	master_data.online_multiplayer_players_my_health = health

remote func game_over(game_status):
	master_data.online_multiplayer_status = game_status
	

func initial_connect_to_server():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")

func connect_to_server():
	if network.get_peer_port(1) != 0:
		master_data.online_multiplayer_is_connected = true
	if network.get_peer_port(1) == 0:
		master_data.online_multiplayer_is_connected = false
		network.create_client(ip, port)
		get_tree().set_network_peer(network)
		
		network.connect("connection_failed", self, "_OnConnectionFailed")
		network.connect("connection_succeeded", self, "_OnConnectionSucceeded")

func _OnConnectionFailed():
	print("Failed to connect")

func _OnConnectionSucceeded():
	print("Successfully Connected")
