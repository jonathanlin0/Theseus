extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 100

func add_text(text):
	var existing_text = $Label.text
	existing_text = text + "\n" + existing_text
	$Label.text = existing_text
	

func _ready():
	
	start_server()


func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")
	

func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")
	add_text("User " + str(player_id) + " Connected")

func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")
	add_text("User " + str(player_id) + " Disconnected")

remote func fetch_test_data():
	var player_id = get_tree().get_rpc_sender_id()
	var return_value = "test successful"
	
	rpc_id(player_id, "return_test_data", return_value)
	add_text("Sent Test Data")
