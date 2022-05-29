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
const ICICLE = preload("res://Weapons/Icicle.tscn")

var knockback = false
var knockback_dir = "left"
var kb_power

var is_multiplayer = false

var prev_music = master_data.music

var temp = 0

# creates a delay between the chest/sign alert text growing and shrinking
var text_can_grow = true

# used to track changes in player health
var previous_health = master_data.health

var is_dead = false

var to_be_deleted_areas = []

var enemies_to_be_checked = []


func _ready():
	if master_data.level == 0:
		$Music/boss_music.play()
	else:
		$Music/stage_music.play()	

func _input(event):
	
	if event is InputEventMouseButton:
		pass

func _physics_process(delta):
	
	
	if prev_music != master_data.music:
		prev_music = master_data.music
		change_music()
	
	if get_tree().get_current_scene().name.find("Multiplayer") != -1:
		master_data.is_multiplayer = true
		is_multiplayer = true
	
	if master_data.is_endless == true:
		$Player_Camera.limit_top = 0
		$Player_Camera.limit_bottom = 270
		$Player_Camera.limit_left = 0
		$Player_Camera.limit_right = 480
	
	if is_multiplayer == true:
		# disable visibility of the hotbar
		$Hotbar/Slot1.visible = false
		$Hotbar/Slot2.visible = false
		$Hotbar/Slot3.visible = false
		$Hotbar/Fire_animation.visible = false
		$Hotbar/lightning_animation.visible = false
		$Hotbar/ice_animation.visible = false
		$Hotbar/Select_border.visible = false
		
		# setting the limits of the camera so it doesn't move around during multiplayer
		$Player_Camera.limit_top = 0
		$Player_Camera.limit_bottom = 270
		$Player_Camera.limit_left = 0
		$Player_Camera.limit_right = 480
		
		# disable visbility of the chest_detection text
		$Object_Hints/CanvasLayer/Actual_Text.visible = false
	
	var speed = master_data.player_speed
	
	# update the master_data values
	master_data.player_x = position.x
	master_data.player_y = position.y
	if is_inside_tree():
		#print(master_data.player_global_y)
		#print(get_global_position().y)
		master_data.player_global_x = get_global_position().x
		master_data.player_global_y = get_global_position().y
		
	
	
	# update the health & mana bars
	
	$StatusBars/MarginContainer/VBoxContainer/HealthBar.max_value = master_data.max_health
	$StatusBars/MarginContainer/VBoxContainer/HealthBar.value = master_data.health
	$StatusBars/MarginContainer/VBoxContainer/HealthBar/HealthLabel.text = str(master_data.health) + "/" + str(master_data.max_health)
	
	$StatusBars/MarginContainer/VBoxContainer/ManaBar.max_value = master_data.max_mana
	$StatusBars/MarginContainer/VBoxContainer/ManaBar.value = master_data.mana
	$StatusBars/MarginContainer/VBoxContainer/ManaBar/ManaLabel.text = str(master_data.mana) + "/" + str(master_data.max_mana)
	
	# movement logic
	
	if knockback && knockback_dir == "left":
		velocity.x = -speed * kb_power * delta * $knockback.time_left
	if knockback && knockback_dir == "right":
		velocity.x = speed * kb_power * delta * $knockback.time_left
	
	if Input.is_key_pressed(KEY_SHIFT):
		sprint = true
	else:
		sprint = false
	
	if master_data.health <= 0:
		master_data.health = 0
		$StatusBars/MarginContainer/VBoxContainer/HealthBar.max_value = master_data.max_health
		$StatusBars/MarginContainer/VBoxContainer/HealthBar.value = master_data.health
		$StatusBars/MarginContainer/VBoxContainer/HealthBar/HealthLabel.text = str(master_data.health) + "/" + str(master_data.max_health)
		dead()
	
	if is_dead == false:
	
		
		# update the master_data values
		master_data.player_x = position.x
		master_data.player_y = position.y
		master_data.player_x_global = global_position.x
		master_data.player_y_global = global_position.y
		
		# make sure health is not negative
		if master_data.health < 0:
			master_data.health = 0
		
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
		if Input.is_action_pressed("ui_3"):
			master_data.selected_weapon = 3
			
		if master_data.selected_weapon == 1:
			$Hotbar/Select_border.rect_position.x = 5
		if master_data.selected_weapon == 2:
			$Hotbar/Select_border.rect_position.x = 5 + 25
		if master_data.selected_weapon == 3:
			$Hotbar/Select_border.rect_position.x = 5 + 25 + 24
		
		if is_multiplayer == false:
			# chest/sign detection text logic
			var sign_close = false
			var chest_close = false
			for obj in $Object_Hints/Chest_Detection.get_overlapping_bodies():
				if obj.name.find("sign") != -1:
					sign_close = true
				if obj.name.find("chest") != -1:
					if obj.opened == false:
						chest_close = true
			
			if sign_close == true and $Object_Hints/CanvasLayer/Actual_Text.visible == false:
				$Object_Hints/CanvasLayer/Actual_Text.text = "Press SPACE to read the sign"
				$Object_Hints/CanvasLayer/Actual_Text.visible = true
			elif chest_close == true and $Object_Hints/CanvasLayer/Actual_Text.visible == false:
				$Object_Hints/CanvasLayer/Actual_Text.text = "Press SPACE to open the chest"
				$Object_Hints/CanvasLayer/Actual_Text.visible = true
			if sign_close == false and chest_close == false:
				$Object_Hints/CanvasLayer/Actual_Text.visible = false
		
		# logic for the chest/sign detection text growing and shrinking in size
		"""
		if $Object_Hints/CanvasLayer/Actual_Text.visible == true and text_can_grow == true:
			
			text_can_grow = false
			$Object_Hints/Text_Delay.start()
			
			
			var max_scale = 1.25
			var min_scale = 0.75
			print("hi")
			
			var tween = $Object_Hints/CanvasLayer/Tween
			
			$Object_Hints/CanvasLayer/Tween.interpolate_property($Object_Hints/CanvasLayer, "scale", Vector2(1.0,1.0), Vector2(max_scale,max_scale), 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
			$Object_Hints/CanvasLayer/Tween.interpolate_property($Object_Hints/CanvasLayer, "scale", Vector2(max_scale,max_scale), Vector2(min_scale, min_scale), 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, 0.3)
			$Object_Hints/CanvasLayer/Tween.interpolate_property($Object_Hints/CanvasLayer, "scale", Vector2(min_scale,min_scale), Vector2(1.0, 1.0), 0.2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, 0.6)
			
			$Object_Hints/CanvasLayer/Tween.start()
		"""
		
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
		
		# logic for player idleing
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
		
		
		
		# animation part of melee logic
		if is_multiplayer == false:
			if Input.is_mouse_button_pressed(BUTTON_RIGHT) and !sword_swinging:
				sword_swinging = true
				$SwordAnimation.visible = true
				if direction == "down":
					$Sound_Effects/Sword.play()
					$SwordAnimation.play("down")
				if direction == "up":
					$Sound_Effects/Sword.play()
					$SwordAnimation.play("up")
				if direction == "left":
					$Sound_Effects/Sword.play()
					$SwordAnimation.play("left")
				if direction == "right":
					$Sound_Effects/Sword.play()
					$SwordAnimation.play("right")
			
			# damage part of melee logic
			
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

		
			if Input.is_action_just_pressed("mouse_left_click"):
				if master_data.selected_weapon == 1 and master_data.mana > master_data.fireball_cost:
					
					$Sound_Effects/Fireball.play()
					
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
					
				if master_data.selected_weapon == 2 and master_data.mana > master_data.lightning_cost:
					
					$Sound_Effects/Lightning.play()
					
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
				
				if master_data.selected_weapon == 3 and master_data.mana > master_data.icicle_cost:
					
					$Sound_Effects/Lightning.play()
					
					master_data.mana -= master_data.icicle_cost
					
					var icicle = ICICLE.instance()
					get_parent().add_child(icicle)
					icicle.position = $Weapon_Holder.global_position
					
					# rotate the icicle to face the direction of the mouse
					var mouseX = get_local_mouse_position().x
					var mouseY = get_local_mouse_position().y
					
					# icicle is backwards when x is neg
					var rad = atan(mouseY/mouseX)
					if mouseX<0:
						rad += PI
					
					icicle.rotate(rad)
		
		# autoaim shooting
		if Input.is_action_just_pressed("ui_c"):
			if is_multiplayer == true:
				if master_data.selected_weapon == 1 and master_data.mana > master_data.fireball_cost:
					
					$Sound_Effects/Fireball.play()
					
					master_data.mana -= master_data.fireball_cost
					
					var fireball = FIREBALL.instance()
					fireball.player_to_hit = 2
					fireball.insert_player(self)
					get_parent().add_child(fireball)
					fireball.position = $Weapon_Holder.global_position
					
					# rotate the fireball to face the direction of player 2
					var dif_x = get_parent().get_node("Player2").global_position.x - global_position.x
					var dif_y = get_parent().get_node("Player2").global_position.y - global_position.y
					var mouseX = get_local_mouse_position().x
					var mouseY = get_local_mouse_position().y
					
					# fireball is backwards when x is neg
					var rad = atan(dif_y/dif_x)
					if dif_x<0:
						rad += PI
					
					fireball.rotate(rad)
			else:
				var close_enemies = []
				for temp in $Enemy_Vision_Area.get_overlapping_bodies():
					for enemy_name in master_data.enemy_names:
						if temp.name.find(enemy_name) != -1 and temp.sees_player == true:
							close_enemies.append(temp)
				
				var shortest_distance = 99999999
				var closest_mob = null
				
				for mob in close_enemies:
					var dif_x = global_position.x - mob.global_position.x
					var dif_y = global_position.y - mob.global_position.y
					var net_distance = abs(sqrt( (dif_x*dif_x) + (dif_y * dif_y)))
				
					if net_distance < shortest_distance:
						shortest_distance = net_distance
						closest_mob = mob
				
				if closest_mob != null:
					if master_data.selected_weapon == 1 and master_data.mana > master_data.fireball_cost:
					
						$Sound_Effects/Fireball.play()
						
						master_data.mana -= master_data.fireball_cost
						
						var fireball = FIREBALL.instance()
						fireball.autoaim = true
						fireball.enemy_to_hit = closest_mob
						get_parent().add_child(fireball)
						fireball.position = $Weapon_Holder.global_position
						
						
						# rotate the fireball to face the direction of the mouse
						var mouseX = closest_mob.global_position.x
						var mouseY = closest_mob.global_position.y
						
						# fireball is backwards when x is neg
						var rad = atan((mouseY - global_position.y)/(mouseX - global_position.y))
						if mouseX<0:
							rad += PI
						
						fireball.rotate(rad)
						
					if master_data.selected_weapon == 2 and master_data.mana > master_data.lightning_cost:
						
						$Sound_Effects/Lightning.play()
						
						master_data.mana -= master_data.lightning_cost
						
						var lightning = LIGHTNING.instance()
						lightning.autoaim = true
						lightning.autoaim_enemy = closest_mob
						get_parent().add_child(lightning)
						lightning.position = $Weapon_Holder.global_position
						
						
						# rotate the lightning to face the direction of the mouse
						var mouseX = closest_mob.global_position.x
						var mouseY = closest_mob.global_position.y
						
						# fireball is backwards when x is neg
						var rad = atan((mouseY - global_position.y)/(mouseX - global_position.y))
						if mouseX<0:
							rad += PI
						
						lightning.rotate(rad)
					
					if master_data.selected_weapon == 3 and master_data.mana > master_data.icicle_cost:
						
						$Sound_Effects/Lightning.play()
						
						master_data.mana -= master_data.icicle_cost
						
						var icicle = ICICLE.instance()
						icicle.autoaim = true
						icicle.autoaim_enemy = closest_mob
						get_parent().add_child(icicle)
						icicle.position = $Weapon_Holder.global_position
						
						# rotate the icicle to face the direction of the mouse
						var mouseX = closest_mob.global_position.x
						var mouseY = closest_mob.global_position.y
						
						# fireball is backwards when x is neg
						var rad = atan((mouseY - global_position.y)/(mouseX - global_position.y))
						if mouseX<0:
							rad += PI
						
						icicle.rotate(rad)
		
			
		if master_data.health < previous_health:
			flash()
		previous_health = master_data.health
			
			
		velocity = move_and_slide(velocity)
	
	# add all the enemies in the area to enemies_in_area
	var enemies_in_area = []
	var enemies_in_area_instance_ids = []
	for obj in $Enemy_Vision_Area.get_overlapping_bodies():
		if obj.name.find("Player") == -1 and enemies_in_area_instance_ids.find(obj.get_instance_id()) == -1:
			var added = false
			for known_enemy in master_data.enemy_names:
				if obj.name.find(known_enemy) != -1 and added == false:
					enemies_in_area.append(obj)
					enemies_in_area_instance_ids.append(obj.get_instance_id())
					added = true
					
	
	# adds all current enemies in the area to the enemies_to_be_checked
	for enemy in enemies_in_area:
		if enemies_to_be_checked.find(enemy) == -1:
			enemies_to_be_checked.append(enemy)
	
	# checks the earliest added enemy in enemies_to_be_checked to see if the enemy/player can see each other
	# have to check the enemies like this one by one instead of all together in a single forloop because a RayShape2D can only check 1 object and its collisions per frame, so in each frame the following section of code checks the enemy vision

	
	if enemies_to_be_checked.size() > 0:
		
		var angle = 0
		
		var wr = weakref(enemies_to_be_checked[0])
		if (wr.get_ref()):
			# to compensate for enemies on the same x values (since can't divide by 0)
			if (enemies_to_be_checked[0].global_position.x - global_position.x) == 0:
				angle = atan((enemies_to_be_checked[0].global_position.y - global_position.y) / (0.000001))
			else:
				angle = atan((enemies_to_be_checked[0].global_position.y - global_position.y) / (enemies_to_be_checked[0].global_position.x - global_position.x))
				
			if enemies_to_be_checked[0].global_position.x - global_position.x < 0:
				angle += PI
				
			var degs = rad2deg(angle)
			$Enemy_Vision_RayShape/CollisionShape2D.rotation = angle - (PI/2)
				
			var enemy_vision_overlapping_bodies = $Enemy_Vision_RayShape.get_overlapping_bodies()
				
			# removes the player object from the list of overlapping bodies
			for obj in enemy_vision_overlapping_bodies:
				if obj.name.find("Player") != -1:
					enemy_vision_overlapping_bodies.erase(obj)
				

			var wall_in_way = false
			for obj in enemy_vision_overlapping_bodies:
				var exists = false
				for known_enemy in master_data.enemy_names:
					if obj.name.find(known_enemy) != -1:
						exists = true
				if exists == false:
					wall_in_way = true
				
			if wall_in_way:
				enemies_to_be_checked[0].sees_player = false
			else:
				enemies_to_be_checked[0].sees_player = true
				
		enemies_to_be_checked.remove(0)
		
	

	# end of physics process function

func dead():
	if master_data.is_multiplayer == false:
		$Sound_Effects/Dead.play()
		$CharacterAnimatedSprite.play("death")
	if master_data.is_multiplayer == true:
		master_data.multiplayer_winner = 2
		get_tree().change_scene("res://Misc/Game_Over_Multiplayer.tscn")
	is_dead = true

func flash():
	# good flash shader tutorial
	# https://www.youtube.com/watch?v=ctevHwoRl24
	$Sound_Effects/Hit.play()
	$CharacterAnimatedSprite.material.set_shader_param("flash_modifier", 1)
	$CharacterAnimatedSprite.material.set_shader_param("flash_color", master_data.colors["white"])
	$SwordAnimation.material.set_shader_param("flash_modifier", 1)
	$SwordAnimation.material.set_shader_param("flash_color", master_data.colors["white"])
	$flash_timer.start(master_data.flash_time)
	

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


func _on_CharacterAnimatedSprite_animation_finished():
	if is_dead == true:
		get_tree().change_scene("res://Misc/Game_Over.tscn")

func _on_Text_Delay_timeout():
	text_can_grow = true
	

func change_music():
	$Music/boss_music.stop()
	$Music/stage_music.stop()
	if prev_music == "stage":
		$Music/stage_music.play()
	if prev_music == "boss":
		$Music/boss_music.play()


func _on_Enemy_Vision_Area_body_exited(body):
	for enemy in master_data.enemy_names:
		if body.name.find(enemy) != -1:
			body.sees_player = false


func _on_Enemy_Vision_Area_body_entered(body):
	for enemy in master_data.enemy_names:
		if body.name.find(enemy) != -1:
			enemies_to_be_checked.append(body)
