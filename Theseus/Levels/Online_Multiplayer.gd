extends Node2D

# instead of using 2 player objects, multiplayer uses 2 online_player objects
# the online_player objects are simpler versions of the player object without as many mechanics

const ONLINE_PLAYER = preload("res://Characters/Online_Player.tscn")
const FIREBALL = preload("res://Weapons/Fireball.tscn")
const ONLINE_FIREBALL = preload("res://Weapons/Online_Fireball.tscn")
var cursor = load("res://Misc/Sprites/cursor_cross.png")

# the direction the player is facing
var direction = "up"

# the object of the current player that the client is controlling
var current_player = null

# this is the vector for the current player's movement
var current_player_velocity = Vector2()

# dictionary of all the fireballs from this player
# every frame, the fireball object updates its position, and every frame the online multiplayer will send the server the fireballs' new location
# when a fireball dies (queue_free()), then it first removes itself from the fireball dictionary that the client sends to the server
var fireballs = {}
"""
The structure for the fireball dictionary on client side goes as follows:
	
{
	fireball_1_instance_id: {
		"position": (2,3),
		"vector": (1,4),
		"angle": (3.14)
	}
	fireball_2_instance_id: {
		"position": (2,3),
		"vector": (1,4),
		"angle": (3.14)
	}
}

On the server side, each one of these client side fireball dictionaries are nested under the user ID that the client is requesting from
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

var enemies_on_screen = {}
"""
Structure:
	
{
	player_server_id: {
		"object": player_obj,
		"position": (2,43)
	},
	player_server_id: {
		"object": player_obj,
		"position": (2,43)
	}
}
"""

# makes sure the ping only changes every 3 seconds
var last_ping_time = 0

func _ready():
	
	Input.set_custom_mouse_cursor(cursor)
	
	
	last_ping_time = OS.get_time().second
	
	Server.connect_to_server()
	Server.fetch_connection()
	
	current_player = ONLINE_PLAYER.instance()
	add_child(current_player)
	
	
	if master_data.online_multiplayer_spawn_quadrant == 0:
		current_player.position = $Player_Spawn_Location.global_position
	elif master_data.online_multiplayer_spawn_quadrant == 1:
		current_player.position = $Quadrants/Q1.global_position
	elif master_data.online_multiplayer_spawn_quadrant == 2:
		current_player.position = $Quadrants/Q2.global_position
	elif master_data.online_multiplayer_spawn_quadrant == 3:
		current_player.position = $Quadrants/Q3.global_position
	elif master_data.online_multiplayer_spawn_quadrant == 4:
		current_player.position = $Quadrants/Q4.global_position
	
	"""
	if master_data.online_multiplayer_is_connected == false:
		current_player.position = $Player_Spawn_Location.global_position

	if master_data.online_multiplayer_players.keys().size() > 0 and master_data.online_multiplayer_is_connected:
		
		Server.fetch_players()
		var avaliable_quads = $Quadrants.get_children()
		
		for given_player in master_data.online_multiplayer_players.keys():
			if master_data.online_multiplayer_players[given_player].x > 240 and master_data.online_multiplayer_players[given_player].x < 480:
				if master_data.online_multiplayer_players[given_player].y > 0 and master_data.online_multiplayer_players[given_player].y < 135:
					avaliable_quads.erase($Quadrants/Q1)
			if master_data.online_multiplayer_players[given_player].x > 0 and master_data.online_multiplayer_players[given_player].x < 240:
				if master_data.online_multiplayer_players[given_player].y > 0 and master_data.online_multiplayer_players[given_player].y < 135:
					avaliable_quads.erase($Quadrants/Q2)
			if master_data.online_multiplayer_players[given_player].x > 0 and master_data.online_multiplayer_players[given_player].x < 240:
				if master_data.online_multiplayer_players[given_player].y > 135 and master_data.online_multiplayer_players[given_player].y < 270:
					avaliable_quads.erase($Quadrants/Q3)
			if master_data.online_multiplayer_players[given_player].x > 240 and master_data.online_multiplayer_players[given_player].x < 480:
				if master_data.online_multiplayer_players[given_player].y > 135 and master_data.online_multiplayer_players[given_player].y < 270:
					avaliable_quads.erase($Quadrants/Q4)
	
	
		if avaliable_quads.size() <= 0:
			current_player.position = $Player_Spawn_Location.global_position
		if avaliable_quads.size() > 0:
			var rand_quad = avaliable_quads[randi() % avaliable_quads.size()]
			current_player.position = rand_quad.global_position
		
		master_data.online_multiplayer_has_spawned = true
	"""

func _physics_process(delta):
	$Ping.text = ("Ping: 10 ms")
	
	#if master_data.online_multiplayer_is_connected:
#		master_data.online_multiplayer_has_spawned = true
	"""
	if master_data.online_multiplayer_has_spawned == false:
		if master_data.online_multiplayer_is_connected == true:
			Server.fetch_players()
			var avaliable_quads = $Quadrants.get_children()
			
			current_player = ONLINE_PLAYER.instance()
			add_child(current_player)
			
			if master_data.online_multiplayer_players.keys().size() <= 0:
				current_player.position = $Player_Spawn_Location.global_position
			
			# if there are multiple enemies
			if master_data.online_multiplayer_players.keys().size() > 0:
				
				print(master_data.online_multiplayer_players)
				
				for given_player in master_data.online_multiplayer_players.keys():
					if master_data.online_multiplayer_players[given_player].x > 240 and master_data.online_multiplayer_players[given_player].x < 480:
						if master_data.online_multiplayer_players[given_player].y > 0 and master_data.online_multiplayer_players[given_player].y < 135:
							avaliable_quads.erase($Quadrants/Q1)
					if master_data.online_multiplayer_players[given_player].x > 0 and master_data.online_multiplayer_players[given_player].x < 240:
						if master_data.online_multiplayer_players[given_player].y > 0 and master_data.online_multiplayer_players[given_player].y < 135:
							avaliable_quads.erase($Quadrants/Q2)
					if master_data.online_multiplayer_players[given_player].x > 0 and master_data.online_multiplayer_players[given_player].x < 240:
						if master_data.online_multiplayer_players[given_player].y > 135 and master_data.online_multiplayer_players[given_player].y < 270:
							avaliable_quads.erase($Quadrants/Q3)
					if master_data.online_multiplayer_players[given_player].x > 240 and master_data.online_multiplayer_players[given_player].x < 480:
						if master_data.online_multiplayer_players[given_player].y > 135 and master_data.online_multiplayer_players[given_player].y < 270:
							avaliable_quads.erase($Quadrants/Q4)
				
				
				if avaliable_quads.size() <= 0:
					current_player.position = $Player_Spawn_Location.global_position
				if avaliable_quads.size() > 0:
					var rand_quad = avaliable_quads[randi() % avaliable_quads.size()]
					current_player.position = rand_quad.global_position
				
			master_data.online_multiplayer_has_spawned = true
	"""
	
	if master_data.online_multiplayer_is_connected == false:
		if OS.get_unix_time() % 3 == 0:
			$No_Connection/ColorRect/Loading_Msg.text = "Trying to establish a connection."
		if OS.get_unix_time() % 3 == 1:
			$No_Connection/ColorRect/Loading_Msg.text = "Trying to establish a connection.."
		if OS.get_unix_time() % 3 == 2:
			$No_Connection/ColorRect/Loading_Msg.text = "Trying to establish a connection..."
		$No_Connection/ColorRect.visible = true
	
	if master_data.online_multiplayer_is_connected:
		
		$No_Connection/ColorRect.visible = false
		
		Server.send_position(current_player.global_position, direction)
		
		
		# this happens when the game is over
		if master_data.online_multiplayer_status == "lose" or master_data.online_multiplayer_status == "win":
			
			# reset the animations for the player to stop moving
			current_player.get_node("AnimatedSprite").play("idle_down")

			
			$Canvas/Online_Multiplayer_Game_Over.visible = true
			if master_data.online_multiplayer_status == "win":
				$Canvas/Online_Multiplayer_Game_Over.set_status("You Won!")
			if master_data.online_multiplayer_status == "lose":
				$Canvas/Online_Multiplayer_Game_Over.set_status("You Lost!")
		
		
		# when the game is not over yet
		if master_data.online_multiplayer_status != "lose" and master_data.online_multiplayer_status != "win":
			
			$Canvas/Online_Multiplayer_Game_Over.visible = false
			
			# update positions in master_data
			master_data.online_multiplayer_player_x = current_player.global_position.x
			master_data.online_multiplayer_player_y = current_player.global_position.y
			
			var currently_running = false
			# sets the appropriate animation
			if Input.is_action_pressed("ui_w") == true:
				current_player.get_node("AnimatedSprite").play("walk_up")
				direction = "up"
				currently_running = true
				
			elif Input.is_action_pressed("ui_s") == true:
				current_player.get_node("AnimatedSprite").play("walk_down")
				direction = "down"
				currently_running = true
				
			if Input.is_action_pressed("ui_a") == true:
				current_player.get_node("AnimatedSprite").play("walk_left")
				direction = "left"
				currently_running = true
				
			elif Input.is_action_pressed("ui_d") == true:
				current_player.get_node("AnimatedSprite").play("walk_right")
				direction = "right"
				currently_running = true
				
			if currently_running == false:
				current_player_velocity.x = 0
				current_player_velocity.y = 0
				if direction == "up":
					current_player.get_node("AnimatedSprite").play("idle_up")
				elif direction == "down":
					current_player.get_node("AnimatedSprite").play("idle_down")
				elif direction == "left":
					current_player.get_node("AnimatedSprite").play("idle_left")
				elif direction == "right":
					current_player.get_node("AnimatedSprite").play("idle_right")
			
			# sets the movement of the player
			if Input.is_action_pressed("ui_w") == true:
				current_player_velocity.y = master_data.player_speed * delta * -1
			elif Input.is_action_pressed("ui_s") == true:
				current_player_velocity.y = master_data.player_speed * delta
			if Input.is_action_pressed("ui_w") == true and Input.is_action_pressed("ui_s") == true:
				current_player_velocity.y = 0
			if Input.is_action_pressed("ui_a") == true:
				current_player_velocity.x = master_data.player_speed * delta * -1
			elif Input.is_action_pressed("ui_d") == true:
				current_player_velocity.x = master_data.player_speed * delta
			if Input.is_action_pressed("ui_a") == true and Input.is_action_pressed("ui_d") == true:
				current_player_velocity.x = 0

			
			current_player.move_and_slide(current_player_velocity)
			
			# set health of the current_player
			Server.fetch_my_health()
			current_player.get_node("Health_Bar").setValue(master_data.online_multiplayer_players_my_health)
			
			# logic for shooting
			if Input.is_action_just_pressed("mouse_left_click"):
				$Sound_Effects/Fireball.play()
				
				master_data.mana -= master_data.fireball_cost
				
				var fireball = FIREBALL.instance()
				add_child(fireball)
				fireball.position = current_player.get_node("Fireball_Spawn").global_position
				
				# rotate the fireball to face the direction of the mouse
				var mouseX = get_global_mouse_position().x - current_player.global_position.x
				var mouseY = get_global_mouse_position().y - current_player.global_position.y
				
				# fireball is backwards when x is neg
				var rad = atan(mouseY/mouseX)
				if mouseX<0:
					rad += PI
				
				fireball.rotate(rad)
				fireballs[fireball.get_instance_id()] = {
					"position":fireball.global_position,
					"vector":fireball.unit_vector,
					"angle":rad
				}
			
			Server.send_fireballs(fireballs)
			
			# ping check
			var start_time = OS.get_ticks_msec()
			Server.fetch_ping(start_time)

			if (OS.get_time().second - last_ping_time) % 3 == 0 and OS.get_time().second != last_ping_time:
				$Ping.text = "Ping: " + str(master_data.online_multiplayer_ping) + " ms"
				last_ping_time = OS.get_time().second
			
			Server.fetch_players()
			Server.fetch_healths()
			
			# spawn enemies in
			for player_id in master_data.online_multiplayer_players.keys():
				if enemies_on_screen.keys().find(player_id) == -1:
					var new_online_player = ONLINE_PLAYER.instance()
					add_child(new_online_player)
					new_online_player.position = master_data.online_multiplayer_players[player_id]
					new_online_player.get_node("AnimatedSprite").play("idle_down")
					new_online_player.get_node("Health_Bar").setMax(100)
					new_online_player.get_node("Health_Bar").setValue(100)
					
					enemies_on_screen[player_id] = {
						"object": new_online_player,
						"position":master_data.online_multiplayer_players[player_id],
						"health":100
					}
					
			var all_enemy_instance_ids = []
			for given_player in master_data.online_multiplayer_players.keys():
				all_enemy_instance_ids.append(given_player)
			
			# remove any players that are not being sent by the server anymore
			for player_instance_id in enemies_on_screen.keys():
				if all_enemy_instance_ids.find(player_instance_id) == -1:
					enemies_on_screen[player_instance_id]["object"].queue_free()
					enemies_on_screen.erase(player_instance_id)
			
			# update enemy positions and direction and health
			for player_instance_id in enemies_on_screen.keys():
				enemies_on_screen[player_instance_id]["object"].position = master_data.online_multiplayer_players[player_instance_id]
				
				var player_directions = master_data.online_multiplayer_players_directions
				if player_directions[player_instance_id] == "down" or player_directions[player_instance_id] == "up":
					if player_directions[player_instance_id] == "down":
						enemies_on_screen[player_instance_id]["object"].get_node("AnimatedSprite").play("idle_down")
					elif player_directions[player_instance_id] == "up":
						enemies_on_screen[player_instance_id]["object"].get_node("AnimatedSprite").play("idle_up")
				else:
					if player_directions[player_instance_id] == "left":
						enemies_on_screen[player_instance_id]["object"].get_node("AnimatedSprite").play("idle_left")
					elif player_directions[player_instance_id] == "right":
						enemies_on_screen[player_instance_id]["object"].get_node("AnimatedSprite").play("idle_right")
				
				enemies_on_screen[player_instance_id]["object"].get_node("Health_Bar").setValue(master_data.online_multiplayer_players_healths[player_instance_id])


			Server.fetch_fireballs()
			master_data.online_multiplayer_fireballs
			var online_fireballs = master_data.online_multiplayer_fireballs
			
			# shows the fireballs on screen
			for given_player in online_fireballs.keys():
				for fireball_instance_id in online_fireballs[given_player].keys():
					if fireballs_on_screen.keys().find(fireball_instance_id) == -1:
						var new_online_fireball = ONLINE_FIREBALL.instance()
						get_parent().add_child(new_online_fireball)
						new_online_fireball.position = online_fireballs[given_player][fireball_instance_id]["position"]
						new_online_fireball.player_id = given_player
						new_online_fireball.rotate(online_fireballs[given_player][fireball_instance_id]["angle"])
						
						
						fireballs_on_screen[fireball_instance_id] = {
							"object":new_online_fireball,
							"position":online_fireballs[given_player][fireball_instance_id]["position"],
							"angle":online_fireballs[given_player][fireball_instance_id]["angle"]
						}
			
			
			var all_fireball_instance_ids = []
			for given_player in online_fireballs.keys():
				for fireball_id in online_fireballs[given_player].keys():
					all_fireball_instance_ids.append(fireball_id)

			# remove all the fireballs that are not being sent by the clients anymore
			for fireball_instance_id in fireballs_on_screen.keys():
				if all_fireball_instance_ids.find(fireball_instance_id) == -1:
					fireballs_on_screen[fireball_instance_id]["object"].die()
					fireballs_on_screen.erase(fireball_instance_id)
			
			# update fireball positions
			for fireball_instance_id in fireballs_on_screen.keys():
				var temp_player_id = fireballs_on_screen[fireball_instance_id]["object"].player_id
				
				fireballs_on_screen[fireball_instance_id]["object"].position = online_fireballs[temp_player_id][fireball_instance_id]["position"]
			
			Server.fetch_healths()


func _on_Fetch_Test_Data_Timer_timeout():
	
	Server.connect_to_server()
	Server.fetch_connection()
