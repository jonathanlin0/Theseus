extends Node2D

var start_time = OS.get_unix_time()
var time_elapsed = 0

const SMALL_SLIME = preload("res://Enemies/Slime/Small_Slime.tscn")


var level = 1

var current_spawned_mobs = []

var spawned = false

func _ready():
	master_data.is_endless = true
	start_time = OS.get_unix_time()
	master_data.level = 0
	master_data._reset_all()
	
func _physics_process(delta):
	time_elapsed = round(OS.get_unix_time() - start_time)
	
	
	if spawned == false:
		if level < 5:
			spawn_mobs("small_slime", level)
			spawned = true
		
	
	if current_spawned_mobs.size() > 0 and spawned == true:
		master_data.endless_mob_deaths.sort()
		current_spawned_mobs.sort()
		if master_data.endless_mob_deaths == current_spawned_mobs:
			master_data.endless_mob_deaths = []
			current_spawned_mobs = []
			spawned = false
			level += 1
	
	
	$CanvasLayer/Level.text = str(level)

func spawn_mobs(mob, number):
	var spawn_locations = []
	if number > 0:
		spawn_locations.append($Spawn_locations/spawn0)
	if number > 1:
		spawn_locations.append($Spawn_locations/spawn90)
	if number > 2:
		spawn_locations.append($Spawn_locations/spawn180)
	if number > 3:
		spawn_locations.append($Spawn_locations/spawn270)
		
	for i in range(0, number):
		var rand_location = spawn_locations[randi() % spawn_locations.size()]
		spawn_locations.erase(rand_location)
		
		var small_slime = SMALL_SLIME.instance()
		get_parent().add_child(small_slime)
		small_slime.global_position = rand_location.global_position
		current_spawned_mobs.append(small_slime.get_instance_id())


func arrays_have_same_content(array1, array2):
	if array1.size() != array2.size(): return false
	for item in array1:
		if !array2.has(item): return false
		if array1.count(item) != array2.count(item): return false
	return true
