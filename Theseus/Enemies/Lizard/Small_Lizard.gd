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
		
		if net_distance <= master_data.small_lizard_attack_range * 1.5:
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
	flash()

func flash():
	$AnimatedSprite.material.set_shader_param("flash_modifier", 1)
	$flash_timer.start(master_data.flash_time)

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


func _on_flash_timer_timeout():
	$AnimatedSprite.material.set_shader_param("flash_modifier", 0)
