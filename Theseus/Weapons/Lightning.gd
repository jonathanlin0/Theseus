extends Area2D

var velocity = Vector2(0,0) 
var unit_vector = Vector2(0,0)

var mouse_position = position

var hit_objects = []

func _ready():
	
	mouse_position = get_global_mouse_position()
	
	# need to offset from player's position
	mouse_position.x -= master_data.player_x
	mouse_position.y -= master_data.player_y
	
	# need to convert the triangle (x and y components) into a unit triangle to maintain a uniform net vector
	unit_vector = master_data.get_unit_vector(mouse_position.x - position.x, mouse_position.y - position.y)
	
func _physics_process(delta):
	
	
	velocity.x = unit_vector.x * master_data.lightning_speed * delta
	velocity.y = unit_vector.y * master_data.lightning_speed * delta
	
	translate(velocity)

# dest is short for destination
func net_distance (current_x, dest_x, current_y, dest_y):
	var net_x = dest_x - current_x
	var net_y = dest_y - current_y
	net_x = abs(net_x)
	net_y = abs(net_y)
	return sqrt((net_x * net_x) + (net_y * net_y))

func _on_Lightning_body_entered(body):
	
	var is_enemy = false
	for enemy_name in master_data.enemy_names:
		if body.name.find(enemy_name) != -1:
			is_enemy = true
	
	if body.name != "Player" and is_enemy == true:
		
		# add the current object that the lightning hit to the list of objects that have been hit
		# do this so that current obj isn't considered when analyzing which obj is the closest to lightning
		hit_objects.append(body.name)
		body.damage(master_data.lightning_damage)

		if $Range.get_overlapping_bodies().size() > 0:
			
			# large distance to start off with
			var shortest_distance = 99999
			var closest_obj = null
			
			for obj in $Range.get_overlapping_bodies():
				
				# for each enemy in the area,
				for given_enemy in master_data.enemy_names:
					if obj.name.find(given_enemy) != -1:
						
						# if obj distance is closer than current closest obj and obj hasn't been hit already
						if hit_objects.find(obj.name) == -1:
							
							# if distance of current obj is closer than the stored closest obj, then current obj is the closest obj
							if net_distance(global_position.x, obj.global_position.x, global_position.y, obj.global_position.y) < shortest_distance:
								shortest_distance = net_distance(global_position.x, obj.global_position.x, global_position.y, obj.global_position.y)
								closest_obj = obj
			
			# closest_obj will be null if no enemies in radius
			if closest_obj != null:
				#print("--")
				#print(closest_obj.name)
				#print(closest_obj.global_position)
				#print(global_position)
				
				# change unit vectorf
				unit_vector = master_data.get_unit_vector(closest_obj.global_position.x - global_position.x, closest_obj.global_position.y - global_position.y)
				
				# add the current obj to list of hit objects so that lightning won
				hit_objects.append(closest_obj.name)
			if closest_obj == null:
				queue_free()
		"""
		var have_other_objs_overlapping = false
		for obj in $Range.get_overlapping_bodies():
			if obj.name != self.name and hit_objects.find(obj.name) == -1:
				have_other_objs_overlapping = true
		if have_other_objs_overlapping == false:
			queue_free()"""
