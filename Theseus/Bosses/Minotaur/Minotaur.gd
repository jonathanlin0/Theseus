extends KinematicBody2D

var velocity = Vector2()

var axe_swinging = false
var jabbing = false

var previous_animation = "idle"

var can_player_take_damage = true

var direction = "left"
var previous_direction = "left"

var health = master_data.minotaur_health

var is_dead = false
var is_frozen = false

var sees_player = false

var rand = RandomNumberGenerator.new()
var rand_x_vel = 20
var rand_y_vel = 20
var dir = "left"

var can_move


func _randomize():
	if !is_frozen:
		rand.randomize()
		rand_x_vel = rand.randf_range(-100, 100)
		rand_y_vel = rand.randf_range(-40, 40)
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

func _physics_process(delta):
	
	if is_dead == false and is_frozen == false:
	
		$Health_Bar.setValue(health)
		
		if axe_swinging == false and jabbing == false:
			$AnimatedSprite.play("idle")
		
		
		var difference_x = master_data.player_x - global_position.x
		var difference_y = master_data.player_y - global_position.y
		
		if !is_dead and can_move:
			var net_distance = 0
			net_distance = sqrt((difference_x * difference_x) + (difference_y * difference_y))
			var collision = move_and_collide(velocity * delta)
			if difference_x < 0:
				dir = "left"
			if difference_x > 0:
				dir = "right"
			if dir == "left":
				scale.x = scale.y * 1
				$Health_Bar.set_rotation(0)
			if dir == "right":
				scale.x = scale.y * -1
				$Health_Bar.set_rotation(3.14159)
			if collision:
				velocity = velocity.bounce(collision.normal)
				_randomize()
		
		
		if abs(difference_x) > 32:
			
			# set of conditions to ensure that the minotaur can move/change directions
			can_move = true
			if axe_swinging == true or $AnimatedSprite.animation == "charge_up":
				can_move = false
			if jabbing == true:
				can_move = false
			
		
		previous_direction = dir
		
		# start the charge up animation if the player is within the minotaur's range
		if previous_animation != "charge_up" and previous_animation != "axe_swing":
			for obj in $Attack_Areas/axe_area.get_overlapping_bodies():
				if obj.name.find("Player") != -1:
					axe_swinging = true
					previous_animation = "charge_up"
					$AnimatedSprite.play("charge_up")
		
		
		# ensures the player can only take damage once per axe swing
		if can_player_take_damage == true and $AnimatedSprite.animation == "axe_swing":
			for obj in $Attack_Areas/axe_area.get_overlapping_bodies():
				if obj.name.find("Player") != -1:
					master_data.health -= master_data.minotaur_axe_damage
					can_player_take_damage = false
					
		# flying animation for the axe swing
		if $AnimatedSprite.animation == "axe_swing" and $AnimatedSprite.frame == 0:
			print(dir)
			if dir == "left":
				velocity.x = -50000 * delta
			if dir == "right":
				velocity.x = 50000 * delta
			velocity.y = 0
			move_and_slide(velocity)
					
		# code for minotaur jab
		if axe_swinging == false and previous_animation != "jab":
			for obj in $Attack_Areas/jab_area.get_overlapping_bodies():
				if obj.name.find("Player") != -1:
					previous_animation = "jab"
					$AnimatedSprite.play("jab")
					jabbing = true
		
		# code for minotaur jab logic
		if jabbing == true and can_player_take_damage == true:
			for obj in $Attack_Areas/jab_area.get_overlapping_bodies():
				if obj.name.find("Player") != -1:
					can_player_take_damage = false
					master_data.health -= master_data.minotaur_jab_damage

func damage(dmg):
	health -= dmg
	#$Enemy_Abstract_Class.knockback()
	$Enemy_Abstract_Class.flash()
	$Enemy_Abstract_Class.damage_text(dmg)
	$Enemy_Abstract_Class.damage_audio()

func _on_AnimatedSprite_animation_finished():
	
	if previous_animation == "charge_up":
		previous_animation = "axe_swing"
		$AnimatedSprite.play("axe_swing")
	elif previous_animation == "axe_swing":
		can_player_take_damage = true
		previous_animation = "idle"
		$AnimatedSprite.play("idle")
		_randomize()
		axe_swinging = false
		jabbing = false
	elif previous_animation == "jab":
		can_player_take_damage = true
		jabbing = false
		axe_swinging = false
		previous_animation = "idle"
		$AnimatedSprite.play("idle")


func _on_flash_timer_timeout():
	$AnimatedSprite.material.set_shader_param("flash_modifier", 0)
