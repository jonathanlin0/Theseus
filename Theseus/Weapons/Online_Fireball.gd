extends Area2D

var player_id = ""

var to_be_killed = false

func _ready():
	pass

func die():
	$AnimatedSprite.play("die")
	to_be_killed = true

func _on_AnimatedSprite_animation_finished():
	if to_be_killed == true:
		queue_free()
