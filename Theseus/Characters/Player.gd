extends KinematicBody2D


# velocity is the player's movement
var velocity = Vector2()

# used to make sure the player can only attack again after the previous attack is finished
var sword_swinging = false

var direction = "right"

# used so that the player can only damage an enemy once per swing
var can_damage = true

var sprint = false

const FIREBALL = preload("res://Weapons/Fireball.tscn")

func _input(event):
	
	if event is InputEventMouseButton:
		pass

func _physics_process(delta):
	
	
	var speed = master_data.player_speed
	
	# update the master_data values
	master_data.player_x = position.x
	master_data.player_y = position.y
	
	# update the health & mana bars
	
	$StatusBars/MarginContainer/VBoxContainer/HealthBar.max_value = master_data.max_health
	$StatusBars/MarginContainer/VBoxContainer/HealthBar.value = master_data.health
	$StatusBars/MarginContainer/VBoxContainer/HealthBar/HealthLabel.text = str(master_data.health) + "/" + str(master_data.max_health)
	
	$StatusBars/MarginContainer/VBoxContainer/ManaBar.max_value = master_data.max_mana
	$StatusBars/MarginContainer/VBoxContainer/ManaBar.value = master_data.mana
	$StatusBars/MarginContainer/VBoxContainer/ManaBar/ManaLabel.text = str(master_data.mana) + "/" + str(master_data.max_mana)
	
	# movement logic
	
	if Input.is_key_pressed(KEY_SHIFT):
		sprint = true
	else:
		sprint = false
	
	if Input.is_action_pressed("ui_d") and !Input.is_action_pressed("ui_a"):
		direction = "right"
		$CharacterAnimatedSprite.play("run_right")
		if sprint:
			velocity.x = speed * delta * 1.2
		else:
			velocity.x = speed * delta
	
	if Input.is_action_pressed("ui_a") and !Input.is_action_pressed("ui_d"):
		direction = "left"
		$CharacterAnimatedSprite.play("run_left")
		if sprint:
			velocity.x = -speed * delta * 1.2
		else:
			velocity.x = -speed * delta
		
	elif !Input.is_action_pressed("ui_a") and !Input.is_action_pressed("ui_d"):
		velocity.x = 0
		
	# horizontal animiations take priority over vertical animations
	if Input.is_action_pressed("ui_w"):
		if !Input.is_action_pressed("ui_a") and !Input.is_action_pressed("ui_d"):
			$CharacterAnimatedSprite.play("run_up")
			direction = "up"
		if sprint:
			velocity.y = -speed * delta * 1.2
		else:
			velocity.y = -speed * delta 
	
	if Input.is_action_pressed("ui_s"):
		if !Input.is_action_pressed("ui_a") and !Input.is_action_pressed("ui_d"):
			$CharacterAnimatedSprite.play("run_down")
			direction = "down"
		if sprint:
			velocity.y = speed * delta * 1.2
		else:
			velocity.y = speed * delta
		
	elif !Input.is_action_pressed("ui_w") and !Input.is_action_pressed("ui_s"):
		velocity.y = 0
	
	if !Input.is_action_pressed("ui_d") and !Input.is_action_pressed("ui_a"):
		if !Input.is_action_pressed("ui_w") and !Input.is_action_pressed("ui_s"):
			if direction == "right":
				$CharacterAnimatedSprite.play("idle_right")
			if direction == "left":
				$CharacterAnimatedSprite.play("idle_left")
			if direction == "up":
				$CharacterAnimatedSprite.play("idle_up")
			if direction == "down":
				$CharacterAnimatedSprite.play("idle_down")
		
	if Input.is_mouse_button_pressed(BUTTON_RIGHT) and !sword_swinging:
		sword_swinging = true
		$SwordAnimation.visible = true
		if direction == "down":
			$SwordAnimation.play("down")
		if direction == "up":
			$SwordAnimation.play("up")
		if direction == "left":
			$SwordAnimation.play("left")
		if direction == "right":
			$SwordAnimation.play("right")
	
	if Input.is_action_just_pressed("mouse_left_click") and master_data.mana > master_data.fireball_cost:
		master_data.mana -= master_data.fireball_cost
		
		var fireball = FIREBALL.instance()
		get_parent().add_child(fireball)
		fireball.position = $Weapon_Holder.global_position
		
		# rotate the fireball to face the direction of the mouse
		var mouseX = get_local_mouse_position().x
		var mouseY = get_local_mouse_position().y
		
		# fireball is backwards when x is neg
		var rad = atan(mouseY/mouseX)
		if mouseX<0:
			rad += PI
		
		fireball.rotate(rad)
	
	if $SwordAnimation.is_playing() and can_damage == true:
		can_damage = false
		
		var area = $SwordSwingAreas/LeftSwordArea
		
		if $SwordAnimation.animation == "left":
			area = $SwordSwingAreas/LeftSwordArea
		if $SwordAnimation.animation == "right":
			area = $SwordSwingAreas/RightSwordArea
		if $SwordAnimation.animation == "down":
			area = $SwordSwingAreas/DownSwordArea
		if $SwordAnimation.animation == "up":
			area = $SwordSwingAreas/UpSwordArea
		
		for obj in area.get_overlapping_bodies():
			for enemy_name in master_data.enemy_names:
				if enemy_name in obj.name:
					obj.damage(master_data.sword_damage * master_data.melee_multiplier)
		
	velocity = move_and_slide(velocity)


func _on_SwordAnimation_animation_finished():
	sword_swinging = false
	can_damage = true
	$SwordAnimation.playing = false
	$SwordAnimation.visible = false


func _on_ManaRecharge_timeout():
	if master_data.mana < master_data.max_mana:
		master_data.mana += 1
