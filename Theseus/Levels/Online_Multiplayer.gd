extends Node2D

const ONLINE_PLAYER = preload("res://Characters/Online_Player.tscn")

# the direction the player is facing
var direction = "up"

# the object of the current player that the client is controlling
var current_player = null


func _ready():
	current_player = ONLINE_PLAYER.instance()
	add_child(current_player)
	current_player.position = $Player_Spawn_Location.global_position

func _physics_process(delta):
	if Input.is_action_pressed("ui_w") == true:
		current_player.get_node("AnimatedSprite").play("walk_up")
		direction = "up"
	elif Input.is_action_pressed("ui_s") == true:
		current_player.get_node("AnimatedSprite").play("walk_down")
		direction = "down"
	elif Input.is_action_pressed("ui_a") == true:
		current_player.get_node("AnimatedSprite").play("walk_left")
		direction = "left"
	elif Input.is_action_pressed("ui_d") == true:
		current_player.get_node("AnimatedSprite").play("walk_right")
		direction = "right"
	else:
		if direction == "up":
			current_player.get_node("AnimatedSprite").play("idle_up")
		elif direction == "down":
			current_player.get_node("AnimatedSprite").play("idle_down")
		elif direction == "left":
			current_player.get_node("AnimatedSprite").play("idle_left")
		elif direction == "right":
			current_player.get_node("AnimatedSprite").play("idle_right")



