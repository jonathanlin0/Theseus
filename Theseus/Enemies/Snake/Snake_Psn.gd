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

var ticks = 0

var player_in_hitbox = false

func _ready():
	player_in_hitbox = false
	$Health_Bar.setMax(master_data.snake_health)

func _physics_process(delta):
	$Health_Bar.setValue(health)
	if !is_dead:
		if health <= 0 && !knockback:
			dead()
		
		if is_dead == false and is_frozen == false:
			
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
		
		for obj in $damage_area.get_overlapping_bodies():
			if obj.name.find("Player") != -1 and previous_animation != "attack":
				#attacking = true
				previous_animation = "charge_up"
				$AnimatedSprite.play("charge_up")
		
		if $AnimatedSprite.animation == "attack" and can_player_take_damage == true and player_in_hitbox:
			master_data.health -= (master_data.snake_dmg_damage / 2)
			#print(get_parent().get_parent())
			if get_parent().get_parent().get_node("Player") != null:
				get_parent().get_parent().get_node("Player")._knockback(dir, 4)
			else:
				get_parent().get_node("Player")._knockback(dir,4)
			
			ticks = 0
			can_player_take_damage = false
			poison()
	elif is_dead:
		position.y -= 4

func dead():
	$AnimatedSprite.play("death")
	$CollisionShape2D.disabled = true
	is_dead = true

func damage(dmg):
	if health > 0:
		health -= dmg
		$Enemy_Abstract_Class.knockback()
		$Enemy_Abstract_Class.flash()
		$Enemy_Abstract_Class.damage_text(dmg)
		$Enemy_Abstract_Class.damage_audio()
	

func poison():
	if ticks <= 4:
		master_data.health -= 5
		$poison.start()


func _on_AnimatedSprite_animation_finished():
	if previous_animation == "charge_up":
		previous_animation = "attack"
		$AnimatedSprite.play("attack")
	elif previous_animation == "attack":
		previous_animation = "idle"
		$AnimatedSprite.play("idle")
		can_player_take_damage = true
	
	if is_dead:
		master_data.endless_mob_deaths.append(get_instance_id())
		queue_free()



func _on_damage_area_body_entered(body):
	if body.name == "Player":
		player_in_hitbox = true


func _on_damage_area_body_exited(body):
	if body.name == "Player":
		player_in_hitbox = false


func _on_poison_timeout():
	if ticks < 4:
		ticks += 1
		poison()
	if ticks > 4:
		ticks = 0

