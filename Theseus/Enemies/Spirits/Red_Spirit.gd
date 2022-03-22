extends KinematicBody2D

var rand = RandomNumberGenerator.new()
var drop = false
var triggered = false
var is_dead = false
var health = master_data.spirit_health
var velocity = Vector2(10, 0)
var knockback = false
var dropped = false

const DAMAGE_TEXT = preload("res://Misc/Damage_Text.tscn")

const EYE = preload("res://Power_Ups/rangedeye_rare.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	$Health_Bar.setMax(master_data.spirit_health)
	rand.randomize();
	var num = rand.randf_range(0, 1)
	if num <= 0.75:
		drop = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Health_Bar.setValue(health)
	if health <= 0:
		dead()
	
	if is_dead == false:
		
		# used for player tracking
		var difference_x = master_data.player_x - global_position.x
		var difference_y = master_data.player_y - global_position.y
		
		var net_distance = 0
		net_distance = sqrt((difference_x * difference_x) + (difference_y * difference_y))
		
		if net_distance <= master_data.spirit_distance:
			
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
	triggered = true
	health -= dmg
	knockback = true
	$knockback.start()
	flash()
	var text = DAMAGE_TEXT.instance()
	text.amount = dmg
	add_child(text)
	$AudioStreamPlayer.play()
	
func flash():
	$AnimatedSprite.material.set_shader_param("flash_modifier", 1)
	$flash_timer.start(master_data.flash_time)

func dead():
	if drop && !dropped:
			var drops = EYE.instance()
			drops.global_position = $Position2D.global_position
			get_parent().add_child(drops)
			dropped = true
	is_dead = true
	$AnimatedSprite.play("dead")

func _on_knockback_timeout():
	knockback = false


func _on_AnimatedSprite_animation_finished():
	if is_dead:
		queue_free()


func _on_flash_timer_timeout():
	$AnimatedSprite.material.set_shader_param("flash_modifier", 0)
