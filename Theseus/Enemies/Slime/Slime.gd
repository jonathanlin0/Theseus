extends KinematicBody2D

var health = master_data.slime_health
var knockback = false
var is_frozen = false
var sees_player = false

# the velocity vector that changes to try to chase the player around
var velocity = Vector2(100,0)

const DAMAGE_TEXT = preload("res://Misc/Damage_Text.tscn")

var is_dead = false

# the object used to spawn the 2 children slime
const SMALL_SLIME = preload("res://Enemies/Slime/Small_Slime.tscn")

var previous_animation = "idle"

# makes sure that the player can't damage the slime while it's dying
var currently_popping = false

#vars for rays so to give the slime "vision"
var vision_angle_total = deg2rad(360)
var ray_diff = deg2rad(2)
var vision = master_data.slime_distance
var player_angle = 0

var diff_x = 0
var diff_y = 0


var can_see = false
	

	

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


func _ready():
	$Health_Bar.setMax(master_data.slime_health)

	#draw the rays for debugging
	#print(position)

func _physics_process(delta):

	
	
	$Health_Bar.setValue(health)
	
	
	if currently_popping == false:
	
		if health <= 0:
			dead()
		
		if is_dead == false and is_frozen == false:

			var difference_x = master_data.player_global_x - global_position.x
			var difference_y = master_data.player_global_y - global_position.y
			
			
			var net_distance = 0
			net_distance = sqrt((difference_x * difference_x) + (difference_y * difference_y))
			
			#if net_distance <= master_data.slime_distance:
			
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
					velocity = -Vector2(sign_x * 50,sign_y * 50) * master_data.knockback_power * pow($Enemy_Abstract_Class/knockback_timer.time_left, 2)
					velocity = move_and_slide(velocity)

func damage(dmg):
	health -= dmg
	$Enemy_Abstract_Class.knockback()
	$Enemy_Abstract_Class.flash()
	$Enemy_Abstract_Class.damage_text(dmg)
	$Enemy_Abstract_Class.damage_audio()
	

func dead():
	currently_popping = true
	previous_animation = "pop"
	$CollisionShape2D.disabled = true
	$AnimatedSprite.play("pop")
	

func _on_AnimatedSprite_animation_finished():
	if previous_animation == "pop":
		
		# spawns two slimes after death
		var small_slime_left = SMALL_SLIME.instance()
		get_parent().add_child(small_slime_left)
		small_slime_left.global_position = $SlimeSpawnLeft.global_position
		
		var small_slime_right = SMALL_SLIME.instance()
		get_parent().add_child(small_slime_right)
		small_slime_right.global_position = $SlimeSpawnRight.global_position
		
		if master_data.is_endless:
			master_data.endless_mob_deaths.append(get_instance_id())
			master_data.endless_current_spawned_mobs.append(small_slime_left.get_instance_id())
			master_data.endless_current_spawned_mobs.append(small_slime_right.get_instance_id())
		
		queue_free()

