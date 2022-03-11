extends Node2D

var dict = {}

func _ready():
	
	$HTTPRequest_test.request("https://theseusleaderboardserver.jonathanlin04.repl.co/test")
	
	$place_1.text = ""
	$place_2.text = ""
	$place_3.text = ""
	

# overall function to fill leaderboard with data from internet
func fill_leaderboard():
	var sorted_names = []
	var sorted_scores = []
	
	

	# this sorts the dictionary by score into sorted_names and sorted_scores
	for player_name in dict["Leaderboard"]:
		var inserted = false

		for i in range(0, len(sorted_scores)):
			if dict["Leaderboard"].get(player_name).get("time_elapsed") < sorted_scores[i]:
				sorted_scores.insert(i, dict["Leaderboard"].get(player_name).get("time_elapsed"))
				sorted_names.insert(i, player_name)
				inserted = true
		if inserted == false:
			sorted_scores.push_back(dict["Leaderboard"].get(player_name).get("time_elapsed"))
			sorted_names.push_back(player_name)
	
	print(sorted_names)

	if len(sorted_names) > 0:
		$place_1.text = "1st: " + sorted_names[0] + " - " + str(sorted_scores[0]) + " points"
	if len(sorted_names) > 1:
		$place_2.text = "2nd: " + sorted_names[1] + " - " + str(sorted_scores[1]) + " points"
	if len(sorted_names) > 2:
		$place_3.text = "3rd: " + sorted_names[2] + " - " + str(sorted_scores[2]) + " points"

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