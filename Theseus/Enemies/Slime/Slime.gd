extends KinematicBody2D

# the velocity vector that changes to try to chase the player around
var velocity = Vector2(100,0)

var knockback = false

var health = master_data.slime_health
var is_dead = false

# the object used to spawn the 2 children slime
const SMALL_SLIME = preload("res://Enemies/Slime/Small_Slime.tscn")

var previous_animation = "idle"

# makes sure that the player can't damage the slime while it's dying
var currently_popping = false

func _ready():
	$Health_Bar.setMax(master_data.slime_health)

func _physics_process(delta):
	
	$Health_Bar.setValue(health)
	
	
	if currently_popping == false:
	
		if health <= 0:
			dead()
		
		if is_dead == false:
			
			# used for player tracking
			var difference_x = master_data.player_x - position.x
			var difference_y = master_data.player_y - position.y
			
			
			var net_distance = 0
			net_distance = sqrt((difference_x * difference_x) + (difference_y * difference_y))
			
			if net_distance <= master_data.slime_distance:
			
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
					velocity = -Vector2(sign_x * 50,sign_y * 50) * master_data.knockback_power * pow($knockback.time_left, 2)
					velocity = move_and_slide(velocity)

func damage(dmg):
	health -= dmg
	$knockback.start()
	knockback = true

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
		small_slime_left.position = $SlimeSpawnLeft.global_position
		
		var small_slime_right = SMALL_SLIME.instance()
		get_parent().add_child(small_slime_right)
		small_slime_right.position = $SlimeSpawnRight.global_position
		
		queue_free()


func _on_knockback_timeout():
	knockback = false
