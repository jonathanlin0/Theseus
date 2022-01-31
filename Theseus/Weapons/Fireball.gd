extends Area2D

var velocity = Vector2(0,0) 
var unit_vector = Vector2(0,0)

var mouse_position = position

var SPEED = 130

func _ready():
	
	# need to offset from player's position
	mouse_position = get_global_mouse_position()
	mouse_position.x -= master_data.player_x
	mouse_position.y -= master_data.player_y
	
	unit_vector = master_data.get_unit_vector(mouse_position.x - position.x, mouse_position.y - position.y)


func _physics_process(delta):
	
	velocity.x = unit_vector.x * SPEED * delta
	velocity.y = unit_vector.y * SPEED * delta
	
	translate(velocity)
