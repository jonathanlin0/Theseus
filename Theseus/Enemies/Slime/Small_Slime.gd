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

func _ready():
	$Health_Bar.setMax(master_data.small_slime_health)

func _physics_process(delta):
	
	$Health_Bar.setValue(health)
	
	if currently_popping == false:
	
		if health <= 0 && !knockback:
			dead()
		
		if is_dead == false:
			
			# used for player tracking
			var difference_x = master_data.player_x - global_position.x
			var difference_y = master_data.player_y - global_position.y
			
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
					velocity = -Vector2(sign_x * 50,sign_y * 50) * (master_data.knockback_power * 1.5) * pow($knockback.time_left, 2)
					velocity = move_and_slide(velocity)

func damage(dmg):
	if health > 0:
		$knockback.start()
		knockback = true
		health -= dmg
		flash()
		var text = DAMAGE_TEXT.instance()
		text.amount = dmg
		add_child(text)
	
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


func _on_flash_timer_timeout():
	$AnimatedSprite.material.set_shader_param("flash_modifier", 0)
