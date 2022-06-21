extends KinematicBody2D

var health = master_data.small_lizard_health
var knockback = false
var is_frozen = false
var sees_player = false

# the velocity vector that changes to try to chase the player around
var velocity = Vector2()

const DAMAGE_TEXT = preload("res://Misc/Damage_Text.tscn")

var triggered = false
var dir = "left"

var moving = false

var rand = RandomNumberGenerator.new()
var rand_x_vel = 0
var rand_y_vel = 0

const SPIT = preload("res://Enemies/Lizard/Lizard_Spit.tscn")

var is_dead = false

var can_shoot = true

var prev_anim

var collision


#vars for rays so to give the lizard "vision"
var vision_angle_total = deg2rad(360)
var ray_diff = deg2rad(2)
var vision = master_data.slime_distance
var player_angle = 0

var diff_x = 0
var diff_y = 0


	
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

func _physics_process(delta):
	

	
	if $Enemy_Abstract_Class.on_screen:
		update_player()
	
	
	$Health_Bar.setValue(health)
	
	if health <= 0:
		dead()
	
	if is_dead == false and is_frozen == false:
		
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
	health -= dmg
	$Enemy_Abstract_Class.knockback()
	$Enemy_Abstract_Class.flash()
	$Enemy_Abstract_Class.damage_text(dmg)
	$Enemy_Abstract_Class.damage_audio()
	

func _on_AnimatedSprite_animation_finished():
	if moving:
		$AnimatedSprite.play("run")
		prev_anim = "run"
	else:
		$AnimatedSprite.play("idle")
		prev_anim = "idle"
	
	if is_dead == true:
		master_data.endless_mob_deaths.append(get_instance_id())
		queue_free()


