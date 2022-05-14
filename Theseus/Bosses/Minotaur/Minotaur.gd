extends KinematicBody2D

const BOSS_GATE = preload("res://Bosses/boss_gate.tscn")
const STAIRS = preload("res://Bosses/stairs.tscn")

var velocity = Vector2()

var axe_swinging = false
var jabbing = false

var previous_animation = "walk"

var can_player_take_damage = true

var direction = "left"
var previous_direction = "left"

var max_health = master_data.minotaur_health
var health = master_data.minotaur_health

var is_dead = false
var is_frozen = false

var sees_player = false

var rand = RandomNumberGenerator.new()
var rand_x_vel = 20
var rand_y_vel = 20
var dir = "left"

var can_move

var triggered = false

var difference_x
var difference_y

# three phases based on health:: 100% - 60% is phase 1, 59% - 30% is phase 2, 29% - 0% is phase 3
var phase = 1

func _ready():
	$Health_Bar.setMax(master_data.minotaur_health)

func _randomize():
	if !is_frozen:
		rand.randomize()
		if phase == 1:
			rand_x_vel = rand.randf_range(-100, 100)
			rand_y_vel = rand.randf_range(-100, 100)
		if phase == 2:
			rand_x_vel = rand.randf_range(-200, 200)
			rand_y_vel = rand.randf_range(-200, 200)
		if phase == 3:
			rand_x_vel = rand.randf_range(-350, 350)
			rand_y_vel = rand.randf_range(-350, 350)
		
		if velocity.x < 60 * phase and velocity.x > 0:
			velocity.x = 60 * phase
			
		if velocity.x > -60 * phase and velocity.x < 0:
			velocity.x = -60 * phase
		
		if velocity.y < 60 * phase and velocity.y > 0:
			velocity.y = 60 * phase
		
		if velocity.y > -60 * phase and velocity.y < 0:
			velocity.y = -60 * phase
		velocity.x = rand_x_vel
		velocity.y = rand_y_vel

func _physics_process(delta):
	$Health_Bar.setValue(health)
	if phase == 1 and health < max_health * .6:
		$AnimatedSprite.modulate = Color( 1, 0.71, 0.76, 1 )
		phase = 2
	if phase == 2 and health < max_health * .3:
		$AnimatedSprite.modulate = Color( 1, 0, 0, 1 )
		phase = 3
	
	difference_x = master_data.player_x - global_position.x
	difference_y = master_data.player_y - global_position.y
	
	if !triggered and master_data.player_x > 10:
		trigger()
	
	
	if is_dead == false and is_frozen == false and triggered:
		
		if axe_swinging == false and jabbing == false:
			$AnimatedSprite.play("walk")
		
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
					$AnimatedSprite.set_speed_scale(rand.randf_range(1, 3))
		
		
		# ensures the player can only take damage once per axe swing
		if can_player_take_damage == true and $AnimatedSprite.animation == "axe_swing":
			for obj in $Attack_Areas/axe_area.get_overlapping_bodies():
				if obj.name.find("Player") != -1:
					obj._knockback(dir, 7)
					master_data.health -= master_data.minotaur_axe_damage
					can_player_take_damage = false
					
		# flying animation for the axe swing
		if $AnimatedSprite.animation == "axe_swing" and $AnimatedSprite.frame == 0:
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
					obj._knockback(dir, 8)
					jabbing = true
		
		# code for minotaur jab logic
		if jabbing == true and can_player_take_damage == true:
			for obj in $Attack_Areas/jab_area.get_overlapping_bodies():
				if obj.name.find("Player") != -1:
					can_player_take_damage = false
					master_data.health -= master_data.minotaur_jab_damage

func damage(dmg):
	if triggered:
		health -= dmg
		#$Enemy_Abstract_Class.knockback()
		$Enemy_Abstract_Class.flash()
		$Enemy_Abstract_Class.damage_text(dmg)
		$Enemy_Abstract_Class.damage_audio()

func trigger():
	triggered = true
	var block = BOSS_GATE.instance()
	block.position.x = -17
	block.position.y = 101
	get_parent().add_child(block)
	_randomize()

func _on_AnimatedSprite_animation_finished():
	
	if previous_animation == "charge_up":
		previous_animation = "axe_swing"
		$AnimatedSprite.set_speed_scale(1);
		$AnimatedSprite.play("axe_swing")
	elif previous_animation == "axe_swing":
		can_player_take_damage = true
		previous_animation = "walk"
		$AnimatedSprite.play("walk")
		_randomize()
		axe_swinging = false
		jabbing = false
	elif previous_animation == "jab":
		can_player_take_damage = true
		jabbing = false
		axe_swinging = false
		previous_animation = "walk"
		$AnimatedSprite.play("walk")


func _on_flash_timer_timeout():
	$AnimatedSprite.material.set_shader_param("flash_modifier", 0)
