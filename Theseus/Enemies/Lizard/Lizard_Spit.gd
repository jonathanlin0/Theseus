extends Area2D

var velocity = Vector2(0,0) 
var unit_vector = Vector2(0,0)

var lizard_pos = Vector2(0,0)
var set_coords = false

func _ready():
	
	#print(get_parent().global_position.x)
	#print(get_parent().global_position.y)
	#print('')
	
	pass

func _physics_process(delta):

	
	velocity.x = unit_vector.x * master_data.lizard_spit_speed * delta
	velocity.y = unit_vector.y * master_data.lizard_spit_speed * delta
	
	
	translate(velocity)

func set_coords(x,y):
	lizard_pos.x = x
	lizard_pos.y = y
	unit_vector = master_data.get_unit_vector(master_data.player_x - lizard_pos.x, master_data.player_y - lizard_pos.y)


func _on_Lizard_Spit_body_entered(body):
	if body.name.find("Small_Lizard") == -1:
		if body.name.find("Player") != -1:
			master_data.health -= master_data.lizard_spit_damage
		queue_free()
