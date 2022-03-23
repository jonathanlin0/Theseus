extends KinematicBody2D

var sleeping = true
var previous_animation = "statue"
var spawning = false
var can_be_damaged = false


var speed = Vector2()
var health = master_data.snake_goddess_health


func _physics_process(delta):
	if master_data.hypotnuse(get_parent().get_child(3).get_global_position(), get_global_position())<100 and sleeping:
		activate()
	

func damage(dmg):
	if can_be_damaged:
		health-=dmg

func activate():
	sleeping = false
	can_be_damaged = true
	$AnimatedSprite.play("activate")
	
func spawn_snake():
	spawning = true
	$AnimatedSprite.play("summon")
	previous_animation = "summon"


func _on_AnimatedSprite_animation_finished():
	if previous_animation == "summon":
		spawning = false
