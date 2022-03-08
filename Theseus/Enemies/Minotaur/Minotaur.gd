extends KinematicBody2D

var velocity = Vector2()

var axe_swinging = false
var jabbing = false

var previous_animation = "idle"

var can_player_take_damage = true

func _physics_process(delta):
	
	if axe_swinging == false and jabbing == false:
		$AnimatedSprite.play("idle")
	
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
		velocity.x = -50000 * delta
		velocity.y = 0
		velocity = move_and_slide(velocity)
				
	# code for minotaur jab
	if axe_swinging == false and previous_animation != "jab":
		for obj in $Attack_Areas/jab_area.get_overlapping_bodies():
			if obj.name.find("Player") != -1:
				previous_animation = "jab"
				$AnimatedSprite.play("jab")
				jabbing = true



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
		jabbing = false
		previous_animation = "idle"
		$AnimatedSprite.play("idle")
