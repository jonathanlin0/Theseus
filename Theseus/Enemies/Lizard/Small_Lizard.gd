extends KinematicBody2D

# the velocity vector that changes to try to chase the player around
var velocity = Vector2(100,0)

const SPIT = preload("res://Enemies/Lizard/Lizard_Spit.tscn")

var health = master_data.small_lizard_health

var is_dead = false

var can_shoot = true

func _ready():
	$Health_Bar.setMax(master_data.small_lizard_health)

func _physics_process(delta):
	
	$Health_Bar.setValue(health)
	
	if health <= 0:
		dead()
	
	if is_dead == false:
		
		# used for player tracking
		var difference_x = master_data.player_x - position.x
		var difference_y = master_data.player_y - position.y

		
		
		if difference_x < 0:
			# facing left
			$AnimatedSprite.flip_h = false
			$spit_spawn_location.position.x = -18
		if difference_x > 0:
			# facing right
			$AnimatedSprite.flip_h = true
			$spit_spawn_location.position.x = 18
			
			
		var net_distance = 0
		net_distance = sqrt((difference_x * difference_x) + (difference_y * difference_y))
		
		if net_distance <= master_data.small_lizard_attack_range:
			if can_shoot == true:
				
				var spit = SPIT.instance()
				get_parent().add_child(spit)
				spit.position = $spit_spawn_location.global_position
				
				spit.set_coords(position.x, position.y)
				
				can_shoot = false
				$ShootingCooldown.start()

func dead():
	$AnimatedSprite.play("death")
	$CollisionShape2D.disabled = true
	is_dead = true


func _on_ShootingCooldown_timeout():
	can_shoot = true

func damage(dmg):
	health -= dmg


func _on_AnimatedSprite_animation_finished():
	if is_dead == true:
		queue_free()
