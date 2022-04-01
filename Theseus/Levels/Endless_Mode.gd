extends Node2D

var start_time = OS.get_unix_time()
var time_elapsed = 0

# preload all the enemy objects required for spawning enemies
const SMALL_LIZARD = preload("res://Enemies/Lizard/Small_Lizard.tscn")
const SMALL_SLIME = preload("res://Enemies/Slime/Small_Slime.tscn")

# what level in endless mode the player is currently on
var level = 1

var num_enemies = 1
var enemy_health_multiplier = 1.0

# all mobs spawned in the current level
var current_spawned_mobs = []

# checks to see if mobs have spawned
var spawned = false

func _ready():
	master_data.is_endless = true
	start_time = OS.get_unix_time()
	master_data.level = 0
	master_data._reset_all()
	
func _physics_process(delta):
	time_elapsed = round(OS.get_unix_time() - start_time)
	
	
	if spawned == false:
		spawn_mobs("small_slime", master_data.endless_num_enemies)
		spawned = true
	
	# proceed to the next level after all mobs are killed
	# if level is odd, then power up the enemies
	# if level is even, then add more enemies
	if current_spawned_mobs.size() > 0 and spawned == true:
		master_data.endless_mob_deaths.sort()
		current_spawned_mobs.sort()
		if master_data.endless_mob_deaths == current_spawned_mobs:
			master_data.endless_mob_deaths = []
			current_spawned_mobs = []
			spawned = false
			level += 1
			
			if level % 2 != 0:
				master_data.endless_health_multiplier += 0.05
			elif level % 2 == 0:
				master_data.endless_num_enemies += 1
				
			var remaining_power_up_spawn_location = $Power_up_spawn_locations.get_children()
			
	
	
	$CanvasLayer/Level.text = "Level: " + str(level)

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

