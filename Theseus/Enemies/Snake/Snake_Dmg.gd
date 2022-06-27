extends KinematicBody2D

var health = master_data.snake_health
var knockback = false
var is_frozen = false
var sees_player = false

const DAMAGE_TEXT = preload("res://Misc/Damage_Text.tscn")

var attacking = false
var previous_animation = "idle"

var can_player_take_damage = true

var is_dead = false


var moving = false

var velocity = Vector2(10, 0)

var dir = "left"

var player_in_hitbox = false

#vars for rays so to give "vision"
var vision_angle_total = deg2rad(360)
var ray_diff = deg2rad(2)
var vision = master_data.snake_distance
var player_angle = 0

var diff_x = 0
var diff_y = 0

var can_see = false

func _ready():
	player_in_hitbox = false
	$Health_Bar.setMax(master_data.snake_health)
	make_ray()


func make_ray():
	var i = 0
	
	var ray_main = RayCast2D.new()
	var ray1 = RayCast2D.new()
	var ray2 = RayCast2D.new()
	ray_main.cast_to = Vector2.UP.rotated(player_angle)*vision
	ray1.cast_to = Vector2.UP.rotated(player_angle+ray_diff)*vision
	ray2.cast_to = Vector2.UP.rotated(player_angle-ray_diff)*vision
	ray_main.enabled = true
	ray1.enabled = true
	ray2.enabled = true
	ray_main.collision_mask = 2
	ray1.collision_mask = 2
	ray2.collision_mask = 2
	add_child(ray1)
	add_child(ray2)
	add_child(ray_main)

#update the angle of player relative to SELF
func update_player():
	diff_x = master_data.player_global_x - global_position.x
	diff_y = master_data.player_global_y - global_position.y
	#print(diff_y)
	if diff_x == 0:
		if diff_y <0:
			player_angle = -PI/2
		if diff_y >0:
			player_angle = PI/2
	else:
		if scale.x == scale.y * -1:
			var stupid = PI/2 - atan2(diff_y, diff_x)
			player_angle = atan2(diff_y, diff_x)+PI/2 + 2*stupid
		else:
			player_angle = atan2(diff_y, diff_x)+PI/2


func orient_rays():
	#orient rays toeward player
	var i = -1
	for ray in get_children():
		if ray.is_class("RayCast2D"):
			ray.cast_to = Vector2.UP.rotated(player_angle+ray_diff*i)*vision
			i=i+1

func _physics_process(delta):
	$Health_Bar.setValue(health)
	
	#See if the rays hit the player
	if can_see:
		update_player()
		orient_rays()
		for ray in get_children():
			if ray.is_class("RayCast2D"):
				if ray.get_collider() != null:
					#print(ray.get_collider().to_string())
					if ray.get_collider().to_string().substr(0, 6) == "Player":
						sees_player = true
						break
					else:
						sees_player = false
				else:
					sees_player = false
	
	if !is_dead:
		if health <= 0 && !knockback:
			dead()
		
		if !is_dead and can_see and sees_player and !is_frozen:
			
			if previous_animation != "idle":
				velocity.x = 0
				velocity.y = 0
			else:
				if position.x > master_data.player_x:
					dir = "left"
					scale.x = scale.y * 1
					$Health_Bar.set_rotation(0)
				if position.x < master_data.player_x:
					dir = "right"
					scale.x = scale.y * -1
					$Health_Bar.set_rotation(3.14159)
				
				# used for player tracking
				var difference_x = master_data.player_x - global_position.x
				var difference_y = master_data.player_y - global_position.y
				
				var net_distance = 0
				net_distance = sqrt((difference_x * difference_x) + (difference_y * difference_y))
				
				if net_distance <= master_data.snake_distance:
				
					var sign_x = 0
					var sign_y = 0
					
					if abs(difference_x) > 16:
						if difference_x > 0:
							sign_x = 1
						elif difference_x < 0:
							sign_x = -1
					if abs(difference_y) > 19:
						if difference_y > 0:
							sign_y = 1
						elif difference_y < 0:
							sign_y = -1
					
					
					if !knockback:
						velocity = Vector2(sign_x * 50,sign_y * 50)
						velocity = move_and_slide(velocity)
					elif knockback:
						velocity = -Vector2(sign_x * 50,sign_y * 50) * (master_data.knockback_power * 1.5) * pow($Enemy_Abstract_Class/knockback_timer.time_left, 2)
						velocity = move_and_slide(velocity)
		if sees_player:
			for obj in $damage_area.get_overlapping_bodies():
				if obj.name.find("Player") != -1 and previous_animation != "attack":
					#attacking = true
					previous_animation = "charge_up"
					$AnimatedSprite.play("charge_up")
		
		
		if $AnimatedSprite.animation == "attack" and can_player_take_damage == true and player_in_hitbox:
			master_data.health -= master_data.snake_dmg_damage
			get_parent().get_parent().get_node("Player")._knockback(dir, 4)
			can_player_take_damage = false
	elif is_dead:
		position.y -= 4

func dead():
	$CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2DHead.set_deferred("disabled", true)
	$AnimatedSprite.play("death")
	
	is_dead = true

func damage(dmg):
	if health > 0:
		health -= dmg
		$Enemy_Abstract_Class.knockback()
		$Enemy_Abstract_Class.flash()
		$Enemy_Abstract_Class.damage_text(dmg)
		$Enemy_Abstract_Class.damage_audio()
	if health <= 0:
		dead()
	

func _on_AnimatedSprite_animation_finished():
	
	if is_dead:
		master_data.endless_mob_deaths.append(get_instance_id())
		queue_free()
	if previous_animation == "charge_up":
		previous_animation = "attack"
		$AnimatedSprite.play("attack")
	elif previous_animation == "attack":
		previous_animation = "idle"
		$AnimatedSprite.play("idle")
		can_player_take_damage = true
	


func _on_knockback_timeout():
	knockback = false


func _on_damage_area_body_entered(body):
	if body.name == "Player":
		player_in_hitbox = true


func _on_damage_area_body_exited(body):
	if body.name == "Player":
		player_in_hitbox = false


func _on_flash_timer_timeout():
	$AnimatedSprite.material.set_shader_param("flash_modifier", 0)


func _on_VisibilityEnabler2D_screen_entered():
	can_see = true


func _on_VisibilityEnabler2D_screen_exited():
	can_see = false
	sees_player = false
