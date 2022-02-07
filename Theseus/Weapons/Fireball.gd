extends Area2D

var velocity = Vector2(0,0) 
var unit_vector = Vector2(0,0)

var mouse_position = position

func _ready():
	
	mouse_position = get_global_mouse_position()
	
	# need to offset from player's position
	mouse_position.x -= master_data.player_x
	mouse_position.y -= master_data.player_y
	
	# need to convert the triangle (x and y components) into a unit triangle to maintain a uniform net vector
	unit_vector = master_data.get_unit_vector(mouse_position.x - position.x, mouse_position.y - position.y)


func _physics_process(delta):
	
	velocity.x = unit_vector.x * master_data.fireball_speed * delta
	velocity.y = unit_vector.y * master_data.fireball_speed * delta
	
	translate(velocity)


func _on_Fireball_body_entered(body):
	if body.name != "Player":
		for enemy in master_data.enemy_names:
			if body.name.find(enemy) != -1:
				body.damage(master_data.fireball_damage)
				
				queue_free()
	if body.name == "black00" or body.name == "black01":
		$AnimatedSprite.play("fireStop")
		queue_free()
