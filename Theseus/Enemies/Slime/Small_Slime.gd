extends KinematicBody2D

# the velocity vector that changes to try to chase the player around
var velocity = Vector2(10,0)

const DAMAGE_TEXT = preload("res://Misc/Damage_Text.tscn")

var health = master_data.small_slime_health
var is_dead = false

var knockback = false

var previous_animation = "idle"

# makes sure that the player can't damage the slime while it's dying
var currently_popping = false

var diff_x = 0
var diff_y = 0

var player_angle = 0



var vision_angle_total = deg2rad(360)
var ray_diff = deg2rad(2)
var vision = master_data.slime_distance

var sees_player = false
var can_see = false

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
	
	#while i <= vision_angle_total/ray_diff:
		#var ray = RayCast2D.new()
		#var angle = ray_diff*i
		#ray.cast_to = Vector2.UP.rotated(angle)*vision
		#ray.add_exception(SMALL_SLIME)
		#ray.enabled = true
		#ray.collision_mask = 2
		#add_child(ray)
		#i=i+1

func _ready():
	$Health_Bar.setMax(master_data.small_slime_health)
	if diff_x == 0:
		if diff_y <0:
			player_angle = -PI/2
		if diff_y >0:
			player_angle = PI/2
	else:
		player_angle = atan(diff_y/diff_x)
	make_ray()

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
		player_angle = atan2(diff_y, diff_x)+PI/2


func _physics_process(delta):
	
	
	
	var difference_x = master_data.player_x - global_position.x
	var difference_y = master_data.player_y - global_position.y
	
	var i = -1
	for ray in get_children():
		if ray.is_class("RayCast2D"):
			ray.cast_to = Vector2.UP.rotated(player_angle+ray_diff*i)*vision
			i=i+1
	
	if can_see:
		update_player()
		for ray in get_children():
			if ray.is_class("RayCast2D"):
				if ray.get_collider() != null:
					#print(ray.get_collider().to_string())
					if ray.get_collider().to_string().substr(0,6) == "Player":
						sees_player = true
						#print("see")
						break
					else:
						sees_player = false
				else:
					sees_player = false
					#print("no see")
	
	
	$Health_Bar.setValue(health)
	
	if currently_popping == false:
	
		if health <= 0:
			dead()
		
		if is_dead == false:
			
			# used for player tracking
			
			
			var net_distance = 0
			net_distance = sqrt((difference_x * difference_x) + (difference_y * difference_y))
			
			if sees_player:
			
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
					velocity = -Vector2(sign_x * 50,sign_y * 50) * (master_data.knockback_power * 1.5) * pow($knockback.time_left, 2)
					velocity = move_and_slide(velocity)

func damage(dmg):
	$knockback.start()
	knockback = true
	health -= dmg
	flash()
	var text = DAMAGE_TEXT.instance()
	text.amount = dmg
	add_child(text)
	$AudioStreamPlayer.play()
	
func flash():
	$AnimatedSprite.material.set_shader_param("flash_modifier", 1)
	$flash_timer.start(master_data.flash_time)

func dead():
	$AnimatedSprite.play("death")
	$CollisionShape2D.disabled = true
	is_dead = true

func _on_AnimatedSprite_animation_finished():
	if is_dead == true:
		queue_free()


func _on_knockback_timeout():
	knockback = false

func _on_VisibilityEnabler2D_screen_entered():
	can_see = true

func _on_VisibilityEnabler2D_screen_exited():
	can_see = false
	sees_player = false


func _on_flash_timer_timeout():
	$AnimatedSprite.material.set_shader_param("flash_modifier", 0)
