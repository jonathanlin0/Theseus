extends Area2D

# the player_id that the fireball belongs to, essentially who shot the fireball
var player_id = ""
var fireball_speed = 250
var velocity = Vector2()
var unit_vector = Vector2()

var damage = 5

var to_be_killed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	

	
	velocity.x = unit_vector.x * fireball_speed * delta
	velocity.y = unit_vector.y * fireball_speed * delta
	
	translate(velocity)

func die():
	to_be_killed = true
	$AnimatedSprite.play("die")

func _on_Fireball_body_entered(body):
	# when a fireball hits an opponent
	if body.name.find("Player") != -1:
		if body.user_id != player_id:
			if get_parent().player_healths.keys().find(body.user_id) != -1:
				get_parent().player_healths[body.user_id] -= damage
			die()


func _on_AnimatedSprite_animation_finished():
	if to_be_killed == true:
		queue_free()
