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


# creates a delay between the chest/sign alert text growing and shrinking
var text_can_grow = true

# used to track changes in player health
var previous_health = master_data.health_p2

var is_dead = false

func _input(event):
	
	if event is InputEventMouseButton:
		pass

func _physics_process(delta):
	
	
	if master_data.health_p2 <= 0:
		dead()
	
	if is_dead == false:
	
		var speed = master_data.player_speed
		
		# update the master_data values
		master_data.player_x_p2 = position.x
		master_data.player_y_p2 = position.y
		master_data.player_x_global_p2 = global_position.x
		master_data.player_y_global_p2 = global_position.y
		
		# update the health & mana bars
		
		$StatusBars/MarginContainer/HBoxContainer/VBoxContainer/HealthBar.max_value = master_data.max_health_p2
		$StatusBars/MarginContainer/HBoxContainer/VBoxContainer/HealthBar.value = master_data.health_p2
		$StatusBars/MarginContainer/HBoxContainer/VBoxContainer/HealthBar/HealthLabel.text = str(master_data.health_p2) + "/" + str(master_data.max_health_p2)
		
		$StatusBars/MarginContainer/HBoxContainer/VBoxContainer/ManaBar.max_value = master_data.max_mana_p2
		$StatusBars/MarginContainer/HBoxContainer/VBoxContainer/ManaBar.value = master_data.mana_p2
		$StatusBars/MarginContainer/HBoxContainer/VBoxContainer/ManaBar/ManaLabel.text = str(master_data.mana_p2) + "/" + str(master_data.max_mana_p2)


		
		# movement logic
		
		if knockback && knockback_dir == "left":
			velocity.x = -speed * kb_power * delta * $knockback.time_left
		if knockback && knockback_dir == "right":
			velocity.x = speed * kb_power * delta * $knockback.time_left
		
		if Input.is_key_pressed(KEY_SHIFT):
			sprint = true
		else:
			sprint = false
		
		if Input.is_action_pressed("ui_arrow_right") and !Input.is_action_pressed("ui_a") and !knockback:
			direction = "right"
			$CharacterAnimatedSprite.play("run_right")
			if sprint:
				velocity.x = speed * delta * 1.2
			else:
				velocity.x = speed * delta
		
		if Input.is_action_pressed("ui_arrow_left") and !Input.is_action_pressed("ui_arrow_right") and !knockback:
			direction = "left"
			$CharacterAnimatedSprite.play("run_left")
			if sprint:
				velocity.x = -speed * delta * 1.2
			else:
				velocity.x = -speed * delta
			
		elif !Input.is_action_pressed("ui_arrow_left") and !Input.is_action_pressed("ui_arrow_right") and !knockback:
			velocity.x = 0
			
		# horizontal animiations take priority over vertical animations
		if Input.is_action_pressed("ui_arrow_up"):
			if !Input.is_action_pressed("ui_arrow_left") and !Input.is_action_pressed("ui_arrow_right"):
				$CharacterAnimatedSprite.play("run_up")
				direction = "up"
			if sprint:
				velocity.y = -speed * delta * 1.2
			else:
				velocity.y = -speed * delta 
		
		if Input.is_action_pressed("ui_arrow_down"):
			if !Input.is_action_pressed("ui_arrow_left") and !Input.is_action_pressed("ui_arrow_right"):
				$CharacterAnimatedSprite.play("run_down")
				direction = "down"
			if sprint:
				velocity.y = speed * delta * 1.2
			else:
				velocity.y = speed * delta
			
		elif !Input.is_action_pressed("ui_arrow_up") and !Input.is_action_pressed("ui_arrow_down"):
			velocity.y = 0
		
		if !Input.is_action_pressed("ui_arrow_right") and !Input.is_action_pressed("ui_arrow_left"):
			if !Input.is_action_pressed("ui_arrow_up") and !Input.is_action_pressed("ui_arrow_down"):
				if direction == "right":
					$CharacterAnimatedSprite.play("idle_right")
				if direction == "left":
					$CharacterAnimatedSprite.play("idle_left")
				if direction == "up":
					$CharacterAnimatedSprite.play("idle_up")
				if direction == "down":
					$CharacterAnimatedSprite.play("idle_down")
			
		
	
		
		
		if Input.is_action_just_pressed("ui_enter"):
			if master_data.selected_weapon == 1 and master_data.mana_p2 > master_data.fireball_cost:
				
				$Sound_Effects/Fireball.play()
				
				master_data.mana_p2 -= master_data.fireball_cost
				
				var fireball = FIREBALL.instance()
				fireball.player_to_hit = 1
				fireball.insert_player(self)
				get_parent().add_child(fireball)
				fireball.position = $Weapon_Holder.global_position
				
				# rotate the fireball to face the direction of the mouse
				var dif_x = get_parent().get_node("Player").global_position.x - global_position.x
				var dif_y = get_parent().get_node("Player").global_position.y - global_position.y
				var mouseX = get_local_mouse_position().x
				var mouseY = get_local_mouse_position().y
					
				# fireball is backwards when x is neg
				var rad = atan(dif_y/dif_x)
				if dif_x<0:
					rad += PI
					
				fireball.rotate(rad)
				
			if master_data.selected_weapon == 2 and master_data.mana_p2 > master_data.lightning_cost:
				
				$Sound_Effects/Lightning.play()
				
				master_data.mana_p2 -= master_data.lightning_cost
				
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
		
		
			
		if master_data.health_p2 != previous_health:
			flash()
		previous_health = master_data.health_p2
			
			
		velocity = move_and_slide(velocity)

func dead():
	if master_data.is_multiplayer == false:
		$CharacterAnimatedSprite.play("death")
	if master_data.is_multiplayer == true:
		master_data.multiplayer_winner = 1
		get_tree().change_scene("res://Misc/Game_Over_Multiplayer.tscn")
	is_dead = true

func flash():
	# good flash shader tutorial
	# https://www.youtube.com/watch?v=ctevHwoRl24
	$Sound_Effects/Hit.play()
	$CharacterAnimatedSprite.material.set_shader_param("flash_modifier", 1)
	$CharacterAnimatedSprite.material.set_shader_param("flash_color", master_data.colors["white"])
	$flash_timer.start(master_data.flash_time)
	

func _knockback(var dir, var powa):
	kb_power = powa
	knockback_dir = dir
	knockback = true
	$knockback.start()

func _on_CharacterAnimatedSprite_animation_finished():
	pass # Replace with function body.


func _on_Mana_Recharge_timeout():
	if master_data.mana_p2 < master_data.max_mana_p2:
		master_data.mana_p2 += 1


func _on_flash_timer_timeout():
	$CharacterAnimatedSprite.material.set_shader_param("flash_modifier", 0)


func _on_knockback_timeout():
	knockback = false
