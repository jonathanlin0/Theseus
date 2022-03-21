extends Node

# master_data serves as a static object
# used to hold information and other global, useful functions
# similar attributes grouped together for easier balance changes for interactions between character, enemies, and bosses

var enemy_names = ["Slime", "Small_Slime", "Small_Lizard", "Lizard_Boss", "Chimera", "Green_Spirit", "Red_Spirit", "Gold_Spirit", "Snake_Dmg", "SnakePsn"]

var username = "testinglol"

# length of flash when a character gets damaged
var flash_time = 0.1

# length of text that appears above an enemy when they get damaged
var damage_text_time = 0.4

# used for score calculations
var start_time
var end_time

var is_multiplayer = false

# player info
var max_health = 100
var health = 100
var max_mana = 100
var mana = 100
var level = 1
var selected_weapon = 1

# data for player 2
var max_health_p2 = 100
var health_p2 = 100
var max_mana_p2 = 100
var mana_p2 = 100

# powerup multipliers
var ranged_multiplier = 1.0
var melee_multiplier = 1.0

# powerup multipliers for player 2
var ranged_multiplier_p2 = 1.0

# player location
var player_x = 0
var player_y = 0
var player_x_global = 0
var player_y_global = 0

# player 2 location
var player_x_p2 = 0
var player_y_p2 = 0
var player_x_global_p2 = 0
var player_y_global_p2 = 0
#global pos
var player_global_x = 0
var player_global_y = 0


# collection of all the enemies' health
var slime_health = 50
var small_slime_health = 30
var snake_health = 40
var small_lizard_health = 35
var lizard_boss_health = 300
var chimera_health = 250
var spirit_health = 50
var snake_goddess_health = 2000

# collection of the distance threshhold for player tracking from enemies
var slime_distance = 225
var chest_distance = 35
var sign_distance = 25
var spirit_distance = 150
var snake_distance = 175

# collection of the attack range of emtities
var small_lizard_attack_range = 150
var fireball_range = 150

# collection of all the speeds
var player_speed = 7000
var fireball_speed = 200
var lightning_speed = 300
var lizard_spit_speed = 180

# how much energy each attack costs
var fireball_cost = 10
var lightning_cost = 25

# how much damage each attack does
var sword_damage = 20
var fireball_damage = 10
var lightning_damage = 30
var lizard_spit_damage = 10
var lizard_boss_slap_damage = 20
var minotaur_axe_damage = 50
var minotaur_jab_damage = 20
var snake_dmg_damage = 20
var chimera_lion_damage = 25
var chimera_goat_damage = 20

# the rare powerup spawn chances
var rare_chance_in_basic_chest = 0.2
var rare_chance_in_rare_chest = 0.4

# power of knockback
var knockback_power = 10

# number of ememies defeated by the player, used to calculate score and spirit spawns
var slimes_def = 0  # each contributes to 20% of a green spirit
var lizards_def = 0  # each contributes to 50% of a green spirit
var snakes_def = 0  # each contributes to 100% of a red spirit
var chimeras_def = 0  # each contributes to 100% of a gold spirit

# scene ordering
var previous_scene = "title"

# for the multiplayer game over scene
var multiplayer_winner = 1

func _reset_all():
	max_health = 100
	health = 100
	max_mana = 100
	mana = 100
	level = 1
	selected_weapon = 1
	ranged_multiplier = 1.0
	melee_multiplier = 1.0
	player_speed = 7000
	slimes_def = 0
	lizards_def = 0
	snakes_def = 0
	chimeras_def = 0
	
func _reset_all_p2():
	max_health_p2 = 100
	health_p2 = 100
	max_mana_p2 = 100
	mana_p2 = 100
	ranged_multiplier_p2 = 1.0

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
