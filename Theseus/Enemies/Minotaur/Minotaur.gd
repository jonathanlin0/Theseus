extends KinematicBody2D

var velocity = Vector2()

var axe_swinging = false
var jabbing = false

var previous_animation = "idle"

var can_player_take_damage = true

var direction = "left"
var previous_direction = "left"

func _physics_process(delta):
	
	if axe_swinging == false and jabbing == false:
		$AnimatedSprite.play("idle")
	
	
	var difference_x = master_data.player_x - global_position.x
	var difference_y = master_data.player_y - global_position.y
	
	if abs(difference_x) > 32:
		
		# set of conditions to ensure that the minotaur can move/change directions
		var can_move = true
		if axe_swinging == true or $AnimatedSprite.animation == "charge_up":
			can_move = false
		if jabbing == true:
			can_move = false
		
		if can_move == true:
		
			if difference_x > 0:
				direction = "right"
			if difference_x < 0:
				direction = "left"
			
			if direction == "right":
				if previous_direction == "left":
					global_position.x += 64
				scale.x = -1
				
			if direction == "left":
				if previous_direction == "right":
					global_position.x -= 64
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


func _on_AnimatedSprite_animation_finished():
	
	if previous_animation == "charge_up":
		previous_animation = "axe_swing"
		$AnimatedSprite.play("axe_swing")
	elif previous_animation == "axe_swing":
		can_player_take_damage = true
		previous_animation = "idle"
		$AnimatedSprite.play("idle")
		axe_swinging = false
	elif previous_animation == "jab":
		can_player_take_damage = true
		jabbing = false
		previous_animation = "idle"
		$AnimatedSprite.play("idle")
