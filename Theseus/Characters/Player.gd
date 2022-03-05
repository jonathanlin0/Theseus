extends KinematicBody2D


# velocity is the player's movement
var velocity = Vector2()

# used to make sure the player can only attack again after the previous attack is finished
var sword_swinging = false

var direction = "right"

# used so that the player can only damage an enemy once per swing
var can_damage = true

# if player is currently sprinting or not
var sprint = false

const FIREBALL = preload("res://Weapons/Fireball.tscn")
const LIGHTNING = preload("res://Weapons/Lightning.tscn")

var knockback = false
var knockback_dir = "left"
var kb_power

# used to track changes in player health
var previous_health = master_data.health

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
	
	# hotbar logic
	if Input.is_action_pressed("ui_1"):
		master_data.selected_weapon = 1
	if Input.is_action_pressed("ui_2"):
		master_data.selected_weapon = 2
		
	if master_data.selected_weapon == 1:
		$Hotbar/Select_border.rect_position.x = 204
	if master_data.selected_weapon == 2:
		$Hotbar/Select_border.rect_position.x = 204 + 36
	
	
	# movement logic
	
	if knockback && knockback_dir == "left":
		velocity.x = -speed * kb_power * delta * $knockback.time_left
	if knockback && knockback_dir == "right":
		velocity.x = speed * kb_power * delta * $knockback.time_left
	
	if Input.is_key_pressed(KEY_SHIFT):
		sprint = true
	else:
		sprint = false
	
	if Input.is_action_pressed("ui_d") and !Input.is_action_pressed("ui_a") and !knockback:
		direction = "right"
		$CharacterAnimatedSprite.play("run_right")
		if sprint:
			velocity.x = speed * delta * 1.2
		else:
			velocity.x = speed * delta
	
	if Input.is_action_pressed("ui_a") and !Input.is_action_pressed("ui_d") and !knockback:
		direction = "left"
		$CharacterAnimatedSprite.play("run_left")
		if sprint:
			velocity.x = -speed * delta * 1.2
		else:
			velocity.x = -speed * delta
		
	elif !Input.is_action_pressed("ui_a") and !Input.is_action_pressed("ui_d") and !knockback:
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
	
	if Input.is_action_just_pressed("mouse_left_click"):
		if master_data.selected_weapon == 1 and master_data.mana > master_data.fireball_cost:
			
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
			
		if master_data.selected_weapon == 2:
			master_data.mana -= master_data.lightning_cost
			
			var lightning = LIGHTNING.instance()
			get_parent().add_child(lightning)
			lightning.position = $Weapon_Holder.global_position
			
			# rotate the lightning to face the direction of the mouse
			var mouseX = get_local_mouse_position().x
			var mouseY = get_local_mouse_position().y
			
			# lightning is backwards when x is neg
			var rad = atan(mouseY/mouseX)
			if mouseX<0:
				rad += PI
			
			lightning.rotate(rad)
	
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
		
	if master_data.health != previous_health:
		flash()
	previous_health = master_data.health
		
		
	velocity = move_and_slide(velocity)

func flash():
	# good flash shader tutorial
	# https://www.youtube.com/watch?v=ctevHwoRl24
	$CharacterAnimatedSprite.material.set_shader_param("flash_modifier", 1)
	$SwordAnimation.material.set_shader_param("flash_modifier", 1)
	$flash_timer.start()
	

func _knockback(var dir, var powa):
	kb_power = powa
	knockback_dir = dir
	knockback = true
	$knockback.start()

func _on_SwordAnimation_animation_finished():
	sword_swinging = false
	can_damage = true
	$SwordAnimation.playing = false
	$SwordAnimation.visible = false


func _on_ManaRecharge_timeout():
	if master_data.mana < master_data.max_mana:
		master_data.mana += 1


func _on_knockback_timeout():
	knockback = false


func _on_flash_timer_timeout():
	$CharacterAnimatedSprite.material.set_shader_param("flash_modifier", 0)
	$SwordAnimation.material.set_shader_param("flash_modifier", 0)
