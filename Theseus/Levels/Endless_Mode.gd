extends Node2D

var start_time = OS.get_unix_time()
var time_elapsed = 0

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
const SMALL_SLIME = preload("res://Enemies/Slime/Small_Slime.tscn")

# what level in endless mode the player is currently on
var level = 1

var num_enemies = 1
var enemy_health_multiplier = 1.0
var percentage_left = 100

# all mobs spawned in the current level
var current_spawned_mobs = []

# to see if level is currently being delayed
var currently_level_delay = false

# checks to see if mobs have spawned
var spawned = false

var delay_start = OS.get_unix_time()
var delay_time_left = 0

func _ready():
	master_data.is_endless = true
	start_time = OS.get_unix_time()
	master_data.level = 0
	master_data._reset_all()
	
func _physics_process(delta):
	time_elapsed = round(OS.get_unix_time() - start_time)
	
	if master_data.player_speed >= 12500:
		if power_ups_common.find(WINGS_COMMON) != -1:
			power_ups_common.erase(WINGS_COMMON)
		if power_ups_rare.find(WINGS_RARE) != -1:
			power_ups_rare.erase(WINGS_RARE)
	
	$CanvasLayer/Level.text = "Level: " + str(level)

	#$CanvasLayer/Level_Delay_Bar.max_value = master_data.endless_level_delay
	$CanvasLayer/Level_Delay_Bar.value = percentage_left
	
	if currently_level_delay == true:
		# turn on the text and bar that shows how much time left until the next level starts
		$CanvasLayer/Level_Warning_Text.visible = true
		$CanvasLayer/Level_Warning_Text.text = "Time until next level: " + str(round($Level_Delay.get_time_left())) + " seconds"
		
		$CanvasLayer/Level_Delay_Bar.visible = true
		$CanvasLayer/Level_Delay_Bar.value = percentage_left
		
	
	if currently_level_delay == false:
		$CanvasLayer/Level_Warning_Text.visible = false
		$CanvasLayer/Level_Delay_Bar.visible = false
		
		if spawned == false:
			spawn_mobs("small_slime", master_data.endless_num_enemies)
			spawned = true
		
		# proceed to the next level after all mobs are killed
		# if level is odd, then power up the enemies
		# if level is even, then add more enemies
		# increase powerups dropped each level by 1 every 3 levels
		if current_spawned_mobs.size() > 0 and spawned == true:
			master_data.endless_mob_deaths.sort()
			current_spawned_mobs.sort()
			if master_data.endless_mob_deaths == current_spawned_mobs:
				
				# reset killed and current mobs
				master_data.endless_mob_deaths = []
				current_spawned_mobs = []
				
				spawned = false
				level += 1
				
				if level % 2 != 0:
					master_data.endless_health_multiplier += 0.05
				elif level % 2 == 0:
					master_data.endless_num_enemies += 1
				if level % 3 == 0:
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
				$CanvasLayer/Level_Delay_Bar_Update.start()
				percentage_left = 100
				$Level_Delay.start(master_data.endless_level_delay)

func spawn_mobs(mob, number):
	var spawn_locations = $Spawn_locations.get_children()

		
	for i in range(0, number):
		var rand_location = spawn_locations[randi() % spawn_locations.size()]
		spawn_locations.erase(rand_location)
		
		var small_slime = SMALL_SLIME.instance()
		get_parent().add_child(small_slime)
		small_slime.global_position = rand_location.global_position
		current_spawned_mobs.append(small_slime.get_instance_id())

# returns a random number within 25% of the given number
func number_random(num):
	var bottom_limit = num * 0.75
	var top_limit = num* 1.25
	return rand_range(bottom_limit, top_limit)



func _on_Level_Delay_timeout():
	currently_level_delay = false


func _on_Level_Delay_Bar_Update_timeout():
	
	# what percent every 0.015 seconds is of the given amount of delay
	# have to use this math instead of unix time cuz unix time doesn't give the time in decimal
	percentage_left -= (0.015/master_data.endless_level_delay)*100
	
	
	$CanvasLayer/Level_Delay_Bar_Update.start()
