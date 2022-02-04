extends KinematicBody2D

# the velocity vector that changes to try to chase the player around
var velocity = Vector2(10,0)

var health = master_data.small_slime_health
var is_dead = false

var previous_animation = "idle"

# makes sure that the player can't damage the slime while it's dying
var currently_popping = false

func _ready():
	$Health_Bar.setMax(master_data.small_slime_health)

func _physics_process(delta):
	
	$Health_Bar.setValue(health)
	
	if currently_popping == false:
	
		if health <= 0:
			dead()
		
		if is_dead == false:
			
			# used for player tracking
			var difference_x = master_data.player_x - position.x
			var difference_y = master_data.player_y - position.y
			
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
			
			velocity = Vector2(sign_x * 50,sign_y * 50)
			
			velocity = move_and_slide(velocity)

func damage(dmg):
	health -= dmg

func dead():
	queue_free()
