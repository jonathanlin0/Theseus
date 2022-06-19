extends Node2D

# instead of using 2 player objects, multiplayer uses 2 online_player objects
# the online_player objects are simpler versions of the player object without as many mechanics

const ONLINE_PLAYER = preload("res://Characters/Online_Player.tscn")
const FIREBALL = preload("res://Weapons/Fireball.tscn")

# the direction the player is facing
var direction = "up"

# the object of the current player that the client is controlling
var current_player = null

# this is the vector for the current player's movement
var current_player_velocity = Vector2()

# dictionary of all the fireballs from this player
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

func _ready():
	current_player = ONLINE_PLAYER.instance()
	add_child(current_player)
	current_player.position = $Player_Spawn_Location.global_position

func _physics_process(delta):
	Server.send_position(current_player.global_position)
	master_data.online_multiplayer_player_x = current_player.global_position.x
	master_data.online_multiplayer_player_y = current_player.global_position.y
	
	# sets the appropriate animation
	if Input.is_action_pressed("ui_w") == true:
		current_player.get_node("AnimatedSprite").play("walk_up")
		direction = "up"
		
	elif Input.is_action_pressed("ui_s") == true:
		current_player.get_node("AnimatedSprite").play("walk_down")
		direction = "down"
		
	if Input.is_action_pressed("ui_a") == true:
		current_player.get_node("AnimatedSprite").play("walk_left")
		direction = "left"
		
	elif Input.is_action_pressed("ui_d") == true:
		current_player.get_node("AnimatedSprite").play("walk_right")
		direction = "right"
		
	else:
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
