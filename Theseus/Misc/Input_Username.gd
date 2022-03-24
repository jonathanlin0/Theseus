extends Node2D

var user_input = ""

var loading = false

func _ready():
	master_data.end_time = OS.get_unix_time()

func _unhandled_input (event:InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		if user_input.length() >= 30 and $Warnings.visible == false:
			# gives a warning if the user's username is over 30 characters
			# doesn't give warning if the currnt input is a backspace
			if str(PoolByteArray([typed_event.unicode])).find("[0]") != 0:
				$Warnings.text = "Warning: 30 character limit"
				$Warnings.visible = true
				$Warning_Timer.start()
		if user_input.length() < 30:
			user_input = user_input + key_typed
			$Player_Name_Input.text = user_input

func _process(delta):
	if loading == false:
		$Player_Name_Input.text = user_input
		
		if Input.is_action_just_pressed("ui_backspace"):
			user_input = user_input.substr(0,user_input.length()-1)
			$Player_Name_Input.text = user_input
		
		if Input.is_action_just_pressed("ui_enter") and user_input.length() == 0:
			if $Warnings.visible == false:
				$Warnings.text = "Please enter your name"
				$Warnings.visible = true
				$Warning_Timer.start()
		
		if Input.is_action_just_pressed("ui_enter") and user_input.find(" ") != -1:
			if $Warnings.visible == false:
				$Warnings.text = "Please remove any spaces in your username"
				$Warnings.visible = true
				$Warning_Timer.start()
		
		if Input.is_action_just_pressed("ui_enter") and user_input.length() > 0:
			if user_input.find(" ") == -1:
				master_data.username = user_input
				var URL = "https://theseusleaderboardserver.jonathanlin04.repl.co/"

				URL = URL + master_data.username + "/" + str(round(master_data.start_time)) + "/" + str(round(master_data.end_time))
				
				# add some code here to write to local file
				# will do for nats
				
				loading = true
				$White_Cover.visible = true
				$Loading_Text.visible = true
				
				$HTTPRequest.request(URL)
	elif loading == true:
		if OS.get_unix_time() % 4 == 0:
			$Loading_Text.text = "Loading"
		if OS.get_unix_time() % 4 == 1:
			$Loading_Text.text = "Loading."
		if OS.get_unix_time() % 4 == 2:
			$Loading_Text.text = "Loading.."
		if OS.get_unix_time() % 4 == 3:
			$Loading_Text.text = "Loading..."

func _on_Timer_timeout():
	$Warnings.visible = false


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	get_tree().change_scene("res://Misc/Leaderboard.tscn")

