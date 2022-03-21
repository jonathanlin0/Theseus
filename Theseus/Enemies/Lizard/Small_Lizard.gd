extends KinematicBody2D

# the velocity vector that changes to try to chase the player around
var velocity = Vector2()

var triggered = false
var dir = "left"

var moving = false

var rand = RandomNumberGenerator.new()
var rand_x_vel = 0
var rand_y_vel = 0

const SPIT = preload("res://Enemies/Lizard/Lizard_Spit.tscn")

var health = master_data.small_lizard_health

var is_dead = false

var can_shoot = true

var prev_anim

var knockback = false

var collision


#vars for rays so to give the lizard "vision"
var vision_angle_total = deg2rad(360)
var ray_diff = deg2rad(2)
var vision = master_data.slime_distance
var player_angle = 0

var diff_x = 0
var diff_y = 0

var sees_player = false
var can_see = false

func make_ray():
	var i = 0
	
	var ray_main = RayCast2D.new()
	var ray1 = RayCast2D.new()
	var ray2 = RayCast2D.new()
	ray_main.cast_to = Vector2.UP.rotated(player_angle)*vision
	ray1.cast_to = Vector2.UP.rotated(player_angle+ray_diff)*vision
	ray2.cast_to = Vector2.UP.rotated(player_angle-ray_diff)*vision
	ray_main.enabled = true
	ray1.enabled = true
	ray2.enabled = true
	ray_main.collision_mask = 2
	ray1.collision_mask = 2
	ray2.collision_mask = 2
	add_child(ray1)
	add_child(ray2)
	add_child(ray_main)
	
func update_player():
	diff_x = master_data.player_global_x - global_position.x
	diff_y = master_data.player_global_y - global_position.y
	#print(diff_y)
	if diff_x == 0:
		if diff_y <0:
			player_angle = -PI/2
		if diff_y >0:
			player_angle = PI/2
	else:
		player_angle = atan2(diff_y, diff_x)+PI/2




func _randomize():
	if triggered:
		rand.randomize()
		rand_x_vel = rand.randf_range(-50, 50)
		rand_y_vel = rand.randf_range(-20, 20)
		velocity.x += rand_x_vel
		velocity.y += rand_y_vel
		
		if velocity.x > 50:
			velocity.x = 50
		
		if velocity.x < -50:
			velocity.x = -50
		
		if velocity.y > 20:
			velocity.y = 20
		
		if velocity.y < -20:
			velocity.y = -20
		
		if velocity.x < 0:
			dir = "left"
		elif velocity.x > 0:
			dir = "right"
		

func _ready():
	$Health_Bar.setMax(master_data.small_lizard_health)
	make_ray()

func _physics_process(delta):
	
	#orient rays toeward player
	var i = -1
	for ray in get_children():
		if ray.is_class("RayCast2D"):
			ray.cast_to = Vector2.UP.rotated(player_angle+ray_diff*i)*vision
			i=i+1
	
	if can_see:
		update_player()
		for ray in get_children():
			if ray.is_class("RayCast2D"):
				if ray.get_collider() != null:
					#print(ray.get_collider().to_string())
					if ray.get_collider().to_string().substr(0, 6) == "Player":
						sees_player = true
						break
					else:
						sees_player = false
				else:
					sees_player = false
	
	
	$Health_Bar.setValue(health)
	
	if health <= 0:
		dead()
	
	if is_dead == false:
		
		# used for player tracking
		var difference_x = master_data.player_x - global_position.x
		var difference_y = master_data.player_y - global_position.y
		
		if dir == "left":
			$AnimatedSprite.flip_h = false
		else:
			$AnimatedSprite.flip_h = true
		
		collision = move_and_collide(velocity * delta)
		if collision:
			velocity = velocity.bounce(collision.normal)
			_randomize()
		
		var net_distance = 0
		net_distance = sqrt((difference_x * difference_x) + (difference_y * difference_y))
		
		if sees_player:
			triggered = true
			if net_distance <= master_data.small_lizard_attack_range:
				$AnimatedSprite.play("load_attack")
				prev_anim = "load_attack"
				if difference_x < 0:
				# facing left
					$AnimatedSprite.flip_h = false
					$spit_spawn_location.position.x = -18
				if difference_x > 0:
				# facing right
					$AnimatedSprite.flip_h = true
					$spit_spawn_location.position.x = 18
				moving = false
				triggered = true
				velocity.x = 0
				velocity.y = 0
				if can_shoot == true:
					
					var spit = SPIT.instance()
					get_parent().add_child(spit)
					spit.global_position = $spit_spawn_location.global_position
					
					spit.set_coords(global_position.x, global_position.y)
					
					can_shoot = false
					$ShootingCooldown.start()
			elif !moving:
				moving = true
				_randomize()

func dead():
	$AnimatedSprite.play("death")
	$CollisionShape2D.disabled = true
	is_dead = true


func _on_ShootingCooldown_timeout():
	can_shoot = true

func damage(dmg):
	triggered = true
	_randomize()
	health -= dmg


func _on_AnimatedSprite_animation_finished():
	if moving:
		$AnimatedSprite.play("run")
		prev_anim = "run"
	else:
		$AnimatedSprite.play("idle")
		prev_anim = "idle"
	
	if is_dead == true:
		queue_free()


func _on_knockback_timeout():
	knockback = false


func _on_VisibilityEnabler2D_screen_entered():
	can_see = true

func _on_VisibilityEnabler2D_screen_exited():
	can_see = false
	sees_player = false
