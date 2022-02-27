extends KinematicBody2D

var axe_swinging = false

var previous_animation = "idle"

var can_player_take_damage = true

func _physics_process(delta):
	
	if axe_swinging == false:
		$AnimatedSprite.play("idle")
	
	# start the charge up animation if the player is within the minotaur's range
	if previous_animation != "charge_up" and previous_animation != "axe_swing":
		for obj in $Attack_Areas/axe_area.get_overlapping_bodies():
			if obj.name.find("Player") != -1:
				axe_swinging = true
				previous_animation = "charge_up"
				$AnimatedSprite.play("charge_up")
	
	if axe_swinging == false:
		for obj in $Attack_Areas/jab_area.get_overlapping_bodies():
			if obj.name.find("Player") != -1:
				previous_animation = "jab"
				$AnimatedSprite.play("jab")
	
	# ensures the player can only take damage once per axe swing
	if can_player_take_damage == true and $AnimatedSprite.animation == "axe_swing":
		for obj in $Attack_Areas/axe_area.get_overlapping_bodies():
			if obj.name.find("Player") != -1:
				master_data.health -= master_data.minotaur_axe_damage
				can_player_take_damage = false
				
	# code for minotaur jab


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
		previous_animation = "idle"
		$AnimatedSprite.play("idle")
