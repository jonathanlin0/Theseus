extends Node2D

var dict = {}

func _ready():
	
	# the leaderboard is first filled with local data
	var file = File.new()
	file.open("res://leaderboard.json", File.READ)
	var text = file.get_as_text()
	dict = parse_json(text)
	file.close()
	
	fill_leaderboard()
	
	$HTTPRequest_test.request("https://theseusleaderboardserver.jonathanlin04.repl.co/test")

func _process(delta):
	if Input.is_action_pressed("ui_space"):
		get_tree().change_scene("res://Menu/Title_Screen.tscn")
		
	
	# for the moving background
	if $Background.position.y >= 390:
		$Background.position.y = -395
	$Background.position.y += 0.12
	


# overall function to fill leaderboard with data from internet
func fill_leaderboard():
	
	$ScrollContainer/Label.text = ""
	
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
				break
		if inserted == false:
			sorted_scores.push_back(dict["Leaderboard"].get(player_name).get("time_elapsed"))
			sorted_names.push_back(player_name)
	


	# place the players onto the leaderboard
	var display_text = ""
	if len(sorted_names) > 0:
		for i in range(0, len(sorted_names)):
			if sorted_names[i] == master_data.username:
				display_text = display_text + "#" + str(i+1) + ": " + sorted_names[i] + " (you) - " + str(sorted_scores[i]) + " " + " seconds" + "\n"
			else:
				display_text = display_text + "#" + str(i+1) + ": " + sorted_names[i] + " - " + str(sorted_scores[i]) + " " + " seconds" + "\n"
		
		$ScrollContainer/Label.text = display_text.substr(0, len(display_text) -1)

func _on_HTTPRequest_test_request_completed(result, response_code, headers, body):
	
	# see if the returned statement is what it is supposed to be
	if body.get_string_from_utf8() == "test":
		var URL = "https://theseusleaderboardserver.jonathanlin04.repl.co/leaderboard"
		#var URL = "https://theseusleaderboardserver.jonathanlin04.repl.co/" + master_data.username + "/" + str(master_data.start_time) + "/" + str(master_data.end_time) + "/"
		$HTTPRequest_leaderboard.request(URL)

func _on_HTTPRequest_leaderboard_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	json = json.result
	
	# check again to see if the received info is valid
	if json != null:
		dict = json
		fill_leaderboard()
