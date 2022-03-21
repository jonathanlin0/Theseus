extends KinematicBody2D

var sleeping = true
var previous_animation = "statue"
var spawning = false




func activate():
	sleeping = false
	$AnimatedSprite.play("activate")
	
func spawn_snake():
	spawning = true
	$AnimatedSprite.play("summon")
	previous_animation = "summon"


func _on_AnimatedSprite_animation_finished():
	if previous_animation == "summon":
		spawning = false
