extends Area2D

var velocity = Vector2(0,0) 
var unit_vector = Vector2(0,0)

var mouse_position = position

var hitSomething = false;

var hit_enemies = []
#var previous_animation = "";

var player_to_hit = 1

var player_that_is_shooting = null
#var previous_animation = "";
#start position of the fireball
var start_pos = Vector2(0,0)
var start = true

func insert_player(player_obj):
	player_that_is_shooting = player_obj

func _ready():
	start_pos.x = global_position.x
	start_pos.y = global_position.y
	
	#print(global_position)
	
	if master_data.is_multiplayer == false:
		mouse_position = get_global_mouse_position()
		
		# need to offset from player's position
		mouse_position.x -= master_data.player_x
		mouse_position.y -= master_data.player_y
		
		# need to convert the triangle (x and y components) into a unit triangle to maintain a uniform net vector
		unit_vector = master_data.get_unit_vector(mouse_position.x - position.x, mouse_position.y - position.y)
	if master_data.is_multiplayer == true:
		
		if player_to_hit == 1:
			unit_vector = master_data.get_unit_vector(master_data.player_x_global - player_that_is_shooting.global_position.x, master_data.player_y_global - player_that_is_shooting.global_position.y)
		if player_to_hit == 2:
			unit_vector = master_data.get_unit_vector(master_data.player_x_global_p2 - player_that_is_shooting.global_position.x, master_data.player_y_global_p2 - player_that_is_shooting.global_position.y)
		

func hypotnuse(start, curr):
	return sqrt(pow(start.x-curr.x, 2)+pow(start.y-curr.y, 2))


func _physics_process(delta):
	
	if start:
		start_pos = global_position
		start = false
	
	var curr_pos = global_position
	#print(curr_pos)
	#print(hypotnuse(start_pos, curr_pos))
	if hypotnuse(start_pos, curr_pos)>=master_data.fireball_range:
		hitSomething = true
		$AnimatedSprite.play("fireStop")
	
	if !hitSomething:
		velocity.x = unit_vector.x * master_data.fireball_speed * delta
		velocity.y = unit_vector.y * master_data.fireball_speed * delta
	
	translate(velocity)


func _on_Fireball_body_entered(body):

	if master_data.is_multiplayer == false:
		if body.name != "Player":
			for enemy in master_data.enemy_names:
				if body.name.find(enemy) != -1 and hit_enemies.find(body.name) == -1:
					body.damage(master_data.fireball_damage * master_data.ranged_multiplier)
					$AnimatedSprite.play("fireStop")
					hitSomething = true
					hit_enemies.append(body.name)
	if master_data.is_multiplayer == true:
		if player_that_is_shooting.name == "Player":
			if body.name == "Player2":
				master_data.health_p2 -= master_data.fireball_damage
		if player_that_is_shooting.name == "Player2":
			if body.name == "Player":
				master_data.health -= master_data.fireball_damage
	if body.name == "TileMap":
		hitSomething = true;
		#previous_animation = "fireStop"
		$AnimatedSprite.play("fireStop")
		$CollisionShape2D.disabled = true
		velocity = Vector2(0,0);
		#queue_free()

func _on_AnimatedSprite_animation_finished():
	#print("REEEE");
	if hitSomething:
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
