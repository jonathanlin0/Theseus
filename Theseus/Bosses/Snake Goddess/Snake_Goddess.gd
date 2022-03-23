extends KinematicBody2D

var sleeping = true
var previous_animation = "statue"
var spawning = false
var can_be_damaged = false
var dead = false

var velocity = Vector2()
var speed = 0
var health = master_data.snake_goddess_health


func _physics_process(delta):
	#activate when the player gets close
	if master_data.hypotnuse(get_parent().get_child(3).get_global_position(), get_global_position())<150 and sleeping:
		activate()
	if !sleeping and !spawning:
		if master_data.hypotnuse(get_parent().get_child(3).get_global_position(), get_global_position()) > 100:
			velocity = master_data.get_unit_vector(get_parent().get_child(3).get_global_position().x-get_global_position().x, get_parent().get_child(3).get_global_position().y-get_global_position().y)*speed
		elif master_data.hypotnuse(get_parent().get_child(3).get_global_position(), get_global_position()) < 100:
			velocity = master_data.get_unit_vector(get_parent().get_child(3).get_global_position().x-get_global_position().x, get_parent().get_child(3).get_global_position().y-get_global_position().y)*-speed
			
		else:
			velocity = 0
		#print (velocity)
		$AnimatedSprite.play("idle")
		
	

func damage(dmg):
	if can_be_damaged:
		health-=dmg
		#flash
	if health <= 0:
		dead = true
		$AnimatedSprite.play("death")
		previous_animation = "death"

func activate():
	#sleeping = false
	#can_be_damaged = true
	$AnimatedSprite.play("activate")
	previous_animation = "activate"
	
func spawn_snake():
	spawning = true
	$AnimatedSprite.play("summon")
	previous_animation = "summon"


func _on_AnimatedSprite_animation_finished():
	if previous_animation == "activate":
		can_be_damaged = true
		sleeping = false
		speed = 50
	if previous_animation == "summon":
		spawning = false
