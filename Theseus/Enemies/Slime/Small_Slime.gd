extends KinematicBody2D

var health = master_data.small_slime_health
var knockback = false
var is_frozen = false
var sees_player = false

# the velocity vector that changes to try to chase the player around
var velocity = Vector2(10,0)

const DAMAGE_TEXT = preload("res://Misc/Damage_Text.tscn")

var is_dead = false

var previous_animation = "idle"

# makes sure that the player can't damage the slime while it's dying
var currently_popping = false

var diff_x = 0
var diff_y = 0

var player_angle = 0

var vision_angle_total = deg2rad(360)
var ray_diff = deg2rad(2)
var vision = master_data.slime_distance


func _ready():
	$Health_Bar.setMax(master_data.small_slime_health)
	if diff_x == 0:
		if diff_y <0:
			player_angle = -PI/2
		if diff_y >0:
			player_angle = PI/2
	else:
		player_angle = atan(diff_y/diff_x)

func update_player():
	diff_x = master_data.player_global_x - global_position.x
	diff_y = master_data.player_global_y - global_position.y
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

	
	$Health_Bar.setValue(health)
	
	if currently_popping == false:
	
		if health <= 0:
			dead()
		
		if is_dead == false and is_frozen == false:

			
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
					velocity = -Vector2(sign_x * 50,sign_y * 50) * (master_data.knockback_power * 1.5) * pow($Enemy_Abstract_Class/knockback_timer.time_left, 2)
					velocity = move_and_slide(velocity)
					

func damage(dmg):
	health -= dmg
	$Enemy_Abstract_Class.knockback()
	$Enemy_Abstract_Class.damage_text(dmg)
	$Enemy_Abstract_Class.damage_audio()
	$Enemy_Abstract_Class.flash()
	

func dead():
	$AnimatedSprite.play("death")
	$CollisionShape2D.disabled = true
	is_dead = true
	

func _on_AnimatedSprite_animation_finished():
	if is_dead == true:
		master_data.endless_mob_deaths.append(get_instance_id())
		queue_free()


