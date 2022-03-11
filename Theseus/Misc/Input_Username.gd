extends Node2D

var user_input = ""



func _unhandled_input (event:InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		if user_input.length() >= 20 and $Warnings.visible == false:
			# gives a warning if the user's username is over 20 characters
			# doesn't give warning if the currnt input is a backspace
			if str(PoolByteArray([typed_event.unicode])).find("[0]") != 0:
				$Warnings.text = "Warning: 20 character limit"
				$Warnings.visible = true
				$Warning_Timer.start()
		if user_input.length() < 20:
			user_input = user_input + key_typed
			$Player_Name_Input.text = user_input

func _process(delta):
	$Player_Name_Input.text = user_input
	
	if Input.is_action_just_pressed("ui_backspace"):
		user_input = user_input.substr(0,user_input.length()-1)
		$Player_Name_Input.text = user_input
	
	if Input.is_action_just_pressed("ui_enter") and user_input.length() == 0:
		if $Warnings.visible == false:
			$Warnings.text = "Please enter your name"
			$Warnings.visible = true
			$Warning_Timer.start()
	
	if Input.is_action_just_pressed("ui_enter") and user_input.length() > 0:
		master_data.username = user_input

func _on_Timer_timeout():
	$Warnings.visible = false
