extends Node

# master_data serves as a static object
# used to hold information and other global, useful functions
# similar attributes grouped together for easier balance changes

var enemy_names = ["Slime", "Small_Slime"]

var health = 100
var mana = 100
var level = 1

var player_x = 0
var player_y = 0

# collection of all the enemies' health
var slime_health = 50
var small_slime_health = 30

var snake_health = 40

# collection of all the speeds
var player_speed = 7500
var fireball_speed = 180

# how much energy each attack costs
var fireball_cost = 5

# how much damage each attack does
var sword_damage = 20
var fireball_damage = 10

func x_direction(x_body, x_other_object):
	var out = 0
	
	var x_difference = x_other_object - x_body
	
	if x_difference > 0:
		return 1
	if x_difference < 0:
		return -1
	
	return out

func y_direction(y_body, y_other_object):
	var out = 0
	
	var y_difference = y_other_object - y_body
	
	if y_difference > 0:
		return 1
	if y_difference < 0:
		return -1
	
	return out

# this function returns the x and y components of a vector in unit vector form (where the hypotenuse = 1)
func get_unit_vector(x_difference, y_difference):
	var hypo = sqrt((x_difference * x_difference) + (y_difference * y_difference))
	
	var out = Vector2(0,0)
	out.x = x_difference / hypo
	out.y = y_difference / hypo
	return out
