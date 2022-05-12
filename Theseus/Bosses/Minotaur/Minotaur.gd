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

func _physics_process(delta):
	
	if is_dead == false and is_frozen == false:
	
		$Health_Bar.setValue(health)
		
		if axe_swinging == false and jabbing == false:
			$AnimatedSprite.play("idle")
		
		
		var difference_x = master_data.player_x - global_position.x
		var difference_y = master_data.player_y - global_position.y
		
		print(difference_x)
		
		if abs(difference_x) > 32:
			
			# set of conditions to ensure that the minotaur can move/change directions
			var can_move = true
			if axe_swinging == true or $AnimatedSprite.animation == "charge_up":
				can_move = false
			if jabbing == true:
				can_move = false
			
			
			#if can_move == true:
			if $AnimatedSprite.animation != "charge_up" and $AnimatedSprite.animation != "axe_swing":
			
				if difference_x > 0:
					direction = "right"
					scale.x = -1
				if difference_x < 0:
					direction = "left"
					scale.x = 1
				
				
		
		previous_direction = direction
		
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
			if direction == "left":
				velocity.x = -50000 * delta
			if direction == "right":
				velocity.x = 50000 * delta
			velocity.y = 0
			velocity = move_and_slide(velocity)
					
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
