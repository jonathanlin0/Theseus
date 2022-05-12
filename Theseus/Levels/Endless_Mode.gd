extends Node2D

var start_time = OS.get_unix_time()
var time_elapsed = 0

var cursor = load("res://Misc/Sprites/cursor_cross.png")

# preload all the powerups
const CUTLER_COMMON = preload("res://Power_Ups/cutler_common.tscn")
const CUTLER_RARE = preload("res://Power_Ups/cutler_rare.tscn")
const HEALTH_COMMON = preload("res://Power_Ups/healthcanister_common.tscn")
const HEALTH_RARE = preload("res://Power_Ups/healthcanister_rare.tscn")
const MANA_COMMON = preload("res://Power_Ups/manacanister_common.tscn")
const MANA_RARE = preload("res://Power_Ups/manacanister_rare.tscn")
const EYE_COMMON = preload("res://Power_Ups/rangedeye_common.tscn")
const EYE_RARE = preload("res://Power_Ups/rangedeye_rare.tscn")
const WINGS_COMMON = preload("res://Power_Ups/wings_common.tscn")
const WINGS_RARE = preload("res://Power_Ups/wings_rare.tscn")

var power_ups_common = [CUTLER_COMMON, HEALTH_COMMON, MANA_COMMON, EYE_COMMON, WINGS_COMMON]
var power_ups_rare = [CUTLER_RARE, HEALTH_RARE, MANA_RARE, EYE_RARE, WINGS_RARE]

# preload all the enemy objects required for spawning enemies
const SMALL_LIZARD = preload("res://Enemies/Lizard/Small_Lizard.tscn")
const BIG_SLIME = preload("res://Enemies/Slime/Slime.tscn")
const SMALL_SLIME = preload("res://Enemies/Slime/Small_Slime.tscn")
const SNAKE_DMG = preload("res://Enemies/Snake/Snake_Dmg.tscn")
const SNAKE_PSN = preload("res://Enemies/Snake/Snake_PSN.tscn")
const CHIMERA = preload("res://Enemies/Chimera/Chimera.tscn")

const IMPLOSION = preload("res://Particle_Effects/Implosion.tscn")
var implosions_to_be_deleted = []

# what level in endless mode the player is currently on
var level = 1

var num_enemies = 1
var enemy_health_multiplier = 1.0
var percentage_left = 100

# to see if level is currently being delayed
var currently_level_delay = false

# checks to see if mobs have spawned
var spawned = false

var delay_start = OS.get_unix_time()
var delay_time_left = 0

# these two variables are temporary storage for the enemies and the locations of each enemy that need to be spawned
var areas_to_spawn = []
var enemies_to_spawn = []

# used for testing. ensure test_level = 0
var test_level = 0

func _ready():
	Input.set_custom_mouse_cursor(cursor)
	master_data.is_endless = true
	start_time = OS.get_unix_time()
	master_data.level = 0
	master_data._reset_all()
	
	master_data.endless_mob_deaths = []
	master_data.endless_current_spawned_mobs = []
	
	
	if test_level != 0:
		level = test_level
		
		
		for i in range(1, test_level):
			
			# adjust enemy health based on test level
			if i % master_data.endless_enemy_health_break:
				master_data.endless_health_multiplier += 0.1
		
			# give powerups based on test level
			if i % master_data.endless_powerup_break:
				master_data.endless_num_power_ups += 1
			
			# automatically powerup the player w/o using powerups by inherently changing the player's values
			var power_ups = ["cutler","health","mana","eye","wings"]
			# randomize randomizes the random seed
			randomize()
			for x in range(0, master_data.endless_num_power_ups):
			
				# 80% chance drop common
				if int(rand_range(0, 100)) > 20:
					
					var power_up = power_ups[randi() % power_ups.size()]
					
					if power_up == "cutler":
						master_data.melee_multiplier += 0.07
					if power_up == "health":
						if (master_data.health < master_data.max_health):
							master_data.health = master_data.health + 75
							if (master_data.health > master_data.max_health):
								master_data.health = master_data.max_health
						else:
							master_data.max_health = master_data.max_health + 10
							master_data.health = master_data.max_health
					if power_up == "mana":
						master_data.max_mana = master_data.max_mana + 50
						master_data.mana = master_data.max_mana
					if power_up == "eye":
						master_data.ranged_multiplier += 0.07
					if power_up == "wings":
						master_data.player_speed += 200
				else:
					var power_up = power_ups[randi() % power_ups.size()]
					
					if power_up == "cutler":
						master_data.melee_multiplier += .2
					if power_up == "health":
						if (master_data.health < master_data.max_health):
							master_data.health = master_data.health + 150
							if (master_data.health > master_data.max_health):
								master_data.health = master_data.max_health
						else:
							master_data.max_health = master_data.max_health + 20
							master_data.health = master_data.max_health
					if power_up == "mana":
						master_data.max_mana = master_data.max_mana + 100
						master_data.mana = master_data.max_mana
					if power_up == "eye":
						master_data.ranged_multiplier += .2
					if power_up == "wings":
						master_data.player_speed += 400
				
				# 20% chance to drop a rare
			
	
func _physics_process(delta):
	time_elapsed = round(OS.get_unix_time() - start_time)

	
	if master_data.player_speed >= master_data.max_speed:
		if power_ups_common.find(WINGS_COMMON) != -1:
			power_ups_common.erase(WINGS_COMMON)
		if power_ups_rare.find(WINGS_RARE) != -1:
			power_ups_rare.erase(WINGS_RARE)
	
	

	$CanvasLayer/Level_Delay_Bar.value = percentage_left
	
	if $Level_Delay.time_left == 0:
		$CanvasLayer/Level_Warning_Text.visible = false
		$CanvasLayer/Level_Delay_Bar.visible = false
	
	if $Level_Delay.time_left > 0:
		# turn on the text and bar that shows how much time left until the next level starts
		$CanvasLayer/Level_Warning_Text.visible = true
		$CanvasLayer/Level_Warning_Text.text = "Time until next level: " + str(round($Level_Delay.get_time_left())) + " seconds"
		
		$CanvasLayer/Level_Delay_Bar.visible = true
		
		# logic for the delay bar moving and displaying how much time left
		percentage_left -= (delta/master_data.endless_level_delay)*100
		$CanvasLayer/Level_Delay_Bar.value = percentage_left
		
	
	if $Level_Delay.time_left <= master_data.implosion_time:
		
		if spawned == false:
			spawn_mobs()
			$CanvasLayer/Level.text = "Level: " + str(level)
			spawned = true
		
		# proceed to the next level after all mobs are killed
		# increase enemy health every other level
		# increase powerups dropped each level by 1 every 5 levels
		if master_data.endless_current_spawned_mobs.size() > 0 and spawned == true:
			master_data.endless_mob_deaths.sort()
			master_data.endless_current_spawned_mobs.sort()
			if master_data.endless_mob_deaths == master_data.endless_current_spawned_mobs:
				
				# reset killed and current mobs
				master_data.endless_mob_deaths = []
				master_data.endless_current_spawned_mobs = []
				
				spawned = false
				level += 1
				
				if level % master_data.endless_enemy_health_break == 0:
					master_data.endless_health_multiplier += 0.1
				if level % master_data.endless_powerup_break == 0:
					master_data.endless_num_power_ups += 1
					
				var remaining_power_up_spawn_location = $Power_up_spawn_locations.get_children()
				
				for i in range(0, master_data.endless_num_power_ups):
					
					# resets the avaliable spots to add powerups if there are no spots left
					if remaining_power_up_spawn_location.size() < 1:
						remaining_power_up_spawn_location = $Power_up_spawn_locations.get_children()
					
					# pick a random spawn location and then remove it from the avaliable list
					var rand_power_up_location = remaining_power_up_spawn_location[randi() % remaining_power_up_spawn_location.size()]
					remaining_power_up_spawn_location.erase(rand_power_up_location)
					
					# 20% chance to drop a rare
					if int(rand_range(0,100)) > 20:
						var power_up = power_ups_common[randi() % power_ups_common.size()].instance()
						get_parent().add_child(power_up)
						power_up.global_position = rand_power_up_location.global_position
					else:
						var power_up = power_ups_rare[randi() % power_ups_rare.size()].instance()
						get_parent().add_child(power_up)
						power_up.global_position = rand_power_up_location.global_position
				
				currently_level_delay = true
				delay_start = OS.get_unix_time()
				percentage_left = 100
				$Level_Delay.start(master_data.endless_level_delay)

func spawn_mobs():

	var spawn_locations = $Spawn_locations.get_children()
	
	# matches each mob name with the actual mob object
	var mob_name_dict = {
		"small_slime" : SMALL_SLIME,
		"big_slime" : BIG_SLIME,
		"small_lizard" : SMALL_LIZARD,
		"snake_dmg" : SNAKE_DMG,
		"snake_psn" : SNAKE_PSN,
		"chimera": CHIMERA
	}
	
	# for every mob
	for key in mob_name_dict.keys():
		if spawn_locations.size() <= 1:
			spawn_locations = $Spawn_locations.get_children()
		

		
		for i in range(0, round(number_of_mobs(key))):
			
			if spawn_locations.size() <= 1:
				spawn_locations = $Spawn_locations.get_children()
			
			var rand_location = spawn_locations[randi() % spawn_locations.size()]
			spawn_locations.erase(rand_location)
			
			areas_to_spawn.append(rand_location)
			enemies_to_spawn.append(mob_name_dict[key])
			
			
	# spawn the implosions
	for current_area in areas_to_spawn:
		var implosion = IMPLOSION.instance()
		implosion.scale.x = 0.07
		implosion.scale.y = 0.07
		add_child(implosion)
		implosion.global_position = current_area.global_position
		implosions_to_be_deleted.append(implosion)
	$Implosion_Timer.start()

func number_of_mobs(mob):
	var x = level
	var out = 0.0
	
	# equations for each type of mob
	if mob == "small_slime":
		if 0 < x and x < 15:
			out = -0.4 * (9500 / (x + 100)) + 40
	if mob == "big_slime":
		if 2 < x and x < 20:
			out = -0.2 * (x-16)*(x-16) + 4
	if mob == "small_lizard":
		if 5 < x and x < 27:
			out = (3000/(-0.1*(x+310))) + 96
	if mob == "snake_dmg":
		if 10 < x and x < 40:
			out = -0.03*(x-30)*(x-30) + 15
	if mob == "snake_psn":
		if 12 < x and x < 42:
			out = -0.03*(x-32)*(x-30) + 15
	if mob == "chimera":
		if 17 < x and x < 50:
			out = -0.03*(x-37)*(x-37) + 13
		
		
	out = round(out)
	if out > 0:
		return out
	return 0

# returns a random number within 25% of the given number
func number_random(num):
	var bottom_limit = num * 0.75
	var top_limit = num* 1.25
	return rand_range(bottom_limit, top_limit)


func _on_Level_Delay_timeout():
	currently_level_delay = false


func _on_Implosion_Timer_timeout():
	# remove all the implosion effects
	for implosion in implosions_to_be_deleted:
		implosion.queue_free()
		
	# spawn all the enemies
	for i in range(0, areas_to_spawn.size()):
		var current_mob = enemies_to_spawn[i].instance()
		$Enemies_Holder.add_child(current_mob)
		current_mob.global_position = areas_to_spawn[i].global_position
		master_data.endless_current_spawned_mobs.append(current_mob.get_instance_id())
	
	# reset everything
	implosions_to_be_deleted = []
	enemies_to_spawn = []
	areas_to_spawn = []
