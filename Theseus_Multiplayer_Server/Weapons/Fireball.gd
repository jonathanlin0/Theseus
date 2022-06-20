extends Area2D

# the player_id that the fireball belongs to, essentially who shot the fireball
var player_id = ""
var fireball_speed = 250
var velocity = Vector2()
var unit_vector = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	

	
	velocity.x = unit_vector.x * fireball_speed * delta
	velocity.y = unit_vector.y * fireball_speed * delta
	
	translate(velocity)


func _on_Fireball_body_entered(body):
	# when a fireball hits an opponent
	if body.name.find("Player") != -1:
		if body.user_id != player_id:
			print("hi")
