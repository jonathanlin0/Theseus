extends Node

# master_data serves as a static object
# used to hold information and other global, useful functions
# similar attributes grouped together for easier balance changes for interactions between character, enemies, and bosses

var enemy_names = ["Slime", "Small_Slime", "Small_Lizard", "Lizard_Boss", "Chimera", "Green_Spirit", "Red_Spirit", "Gold_Spirit", "Snake_Dmg", "SnakePsn", "Snake_Psn", "Snake_Goddess", "Minotaur"]
var powerups = ["cutler_common", "cutler_rare", "healthcanister_common", "healthcanister_rare", "manacanister_common", "manacanister_rare", "rangedeye_common", "rangedeye_rare", "wings_common", "wings_rare"]
var colors = {
	"red":Vector3(1.0, 0, 0),
	"green":Vector3(0.0, 1.0, 0),
	"blue":Vector3(0.0, 0.0, 1),
	"light_blue":Vector3(0.52,0.82,1),
	"white":Vector3(1.0,1.0,1.0)
}

var username = "user"

var endless_current_spawned_mobs = []
# used to track when mobs die
var endless_mob_deaths = []
# enemy health multiplier for endless mode
var endless_health_multiplier = 1.0
# number of enemies spawned per level for endless mode
var endless_num_enemies = 1
# number of powerups spawned after each level for endless mode
var endless_num_power_ups = 1
# amount of seconds between each level, typically used to collect the powerups
var endless_level_delay = 5.0
# every x levels that the enemy increases by 0.1% health
var endless_enemy_health_break = 2
# every x levels that num of powerups increases by 1
var endless_powerup_break = 5

# variable to see if the client is connected to a server
var online_multiplayer_is_connected = false
# see if current player has spawned yet for online multipler
var online_multiplayer_has_spawned = false
# which spot the player will spawn in
var online_multiplayer_spawn_quadrant = 0
# holds all the positions of the online multiplayer enemies
var online_multiplayer_players = {}
# holds all the directions of the online multiplayer enemies
var online_multiplayer_players_directions = {}
# holds all the directions of the online multiplayer enemies
var online_multiplayer_players_healths = {}
# holds the current client player's health
var online_multiplayer_players_my_health = 100
# online_multiplayer_status can be "win" or "lose". it will change to one of them after the server signals that the game is over and their placement
var online_multiplayer_status = ""
var online_multiplayer_ping = 0
# position of current player
var online_multiplayer_player_x = 0
var online_multiplayer_player_y = 0
var online_multiplayer_fireballs = {}

# time for the implosion effect
var implosion_time = 1.0

# length of flash when a character gets damaged
var flash_time = 0.1

# length of time for enemy to remain frozen after icicle hits them
var freeze_time = 2.0

# length of text that appears above an enemy when they get damaged
var damage_text_time = 0.4

var visible_enemies = []

# used for score calculations
var start_time = OS.get_unix_time()
var end_time = OS.get_unix_time() + 5021

var is_multiplayer = false
var is_endless = false

# player info
var max_health = 100
var health = 100
var max_mana = 100
var mana = 100
var level = 1
var selected_weapon = 1
var max_speed = 12500

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

# collection of all the enemies' base health
var base_slime_health = 50
var base_small_slime_health = 30
var base_snake_health = 40
var base_small_lizard_health = 35
var base_lizard_boss_health = 300
var base_chimera_health = 250
var base_spirit_health = 50
var base_snake_goddess_health = 500
var base_minotaur_health = 2000

# collection of all the enemies' health that can change depending on situation that the player is currently in (like enemies increasing in strength in endless mode)
var slime_health = 50
var small_slime_health = 30
var snake_health = 40
var small_lizard_health = 35
var lizard_boss_health = 300
var chimera_health = 250
var spirit_health = 50
var snake_goddess_health = 500
var minotaur_health = 2000

# collection of the distance threshhold for player tracking from enemies
var slime_distance = 225
var chest_distance = 35
var sign_distance = 25
var spirit_distance = 150
var snake_distance = 200

# collection of the attack range of emtities
var small_lizard_attack_range = 150
var fireball_range = 150
var icicle_range = 150

# collection of all the speeds
var player_speed = 7000
var fireball_speed = 250
var icicle_speed = 200
var lightning_speed = 300
var lizard_spit_speed = 180

# how much energy each attack costs
var fireball_cost = 10
var lightning_cost = 25
var icicle_cost = 30

# how much damage each attack does
var sword_damage = 20
var fireball_damage = 10
var lightning_damage = 30
var icicle_damage = 20
var lizard_spit_damage = 10
var lizard_boss_slap_damage = 20
var minotaur_axe_damage = 50
var minotaur_jab_damage = 20
var snake_dmg_damage = 20
var chimera_lion_damage = 25
var chimera_goat_damage = 20
var snake_goddess_whack_damage = 15

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
var music = "stage"

# for the multiplayer game over scene
var multiplayer_winner = 1

func _reset_all():
	max_health = 100
	health = 100
	max_mana = 100
	mana = 100
	level = 0
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
	
func _process(delta):
	if !is_endless:
		endless_health_multiplier = 1.0
	
	slime_health = base_slime_health * endless_health_multiplier
	small_slime_health = base_small_slime_health * endless_health_multiplier
	snake_health = base_snake_health * endless_health_multiplier
	small_lizard_health = base_small_lizard_health * endless_health_multiplier
	lizard_boss_health = base_lizard_boss_health * endless_health_multiplier
	chimera_health = base_chimera_health * endless_health_multiplier
	spirit_health = base_spirit_health * endless_health_multiplier
	snake_goddess_health = base_snake_goddess_health * endless_health_multiplier

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
	
	if hypo == 0:
		out.x = 0
		out.y = 1
	else:
		out.x = x_difference / hypo
		out.y = y_difference / hypo
	
	return out

#returns the hypotnuse length given 2 positions
func hypotnuse(start, curr):
	return sqrt(pow(start.x-curr.x, 2)+pow(start.y-curr.y, 2))
