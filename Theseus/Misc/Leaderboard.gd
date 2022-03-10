extends Node2D

var dict = {}

func _ready():
	
	$HTTPRequest_test.request("https://theseusleaderboardserver.jonathanlin04.repl.co/test")
	
	
	
	"""
	var file = File.new()
	file.open("res://leaderboard.json", File.READ)
	var text = file.get_as_text()
	dict = JSON.parse(text)
	file.close()
	
	print(text)
	"""

# overall function to fill leaderboard with data from internet
func fill_leaderboard():
	var sorted_dict = []

	print(dict)

# assign the dict using the local leaderboard file
func load_local_data():
	var file = File.new()
	file.open("res://leaderboard.json", File.READ)
	var text = file.get_as_text()
	dict = JSON.parse(text)
	file.close()
	
	fill_leaderboard()

func _on_HTTPRequest_test_request_completed(result, response_code, headers, body):
	
	# if there is an error retrieving info from the server, then fill up the leaderboard using local data
	if body.get_string_from_utf8() != "test":
		load_local_data()
	else:
		var URL = "https://theseusleaderboardserver.jonathanlin04.repl.co/leaderboard"
		#var URL = "https://theseusleaderboardserver.jonathanlin04.repl.co/" + master_data.username + "/" + str(master_data.start_time) + "/" + str(master_data.end_time) + "/"
		print(URL)
		$HTTPRequest_leaderboard.request(URL)

func _on_HTTPRequest_leaderboard_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	json = json.result
	
	# check again to see if the received info is valid
	if json == null:
		load_local_data()
	else:
		dict = json
		fill_leaderboard()
