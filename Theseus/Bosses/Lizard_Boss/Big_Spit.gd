extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity = Vector2(0,0) 
var unit_vector = Vector2(0,0)

var lizard_pos = Vector2(0,0)
var set_coords = false

var pop = false
var kb_dir

const SLIME = preload("res://Enemies/Slime/Small_Slime.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	
	if !pop:
		velocity.x = unit_vector.x * master_data.lizard_spit_speed * delta
		velocity.y = unit_vector.y * master_data.lizard_spit_speed * delta
		translate(velocity)

func set_coords(x,y):
	lizard_pos.x = x
	lizard_pos.y = y
	unit_vector = master_data.get_unit_vector(master_data.player_x - lizard_pos.x, master_data.player_y - lizard_pos.y)


func _on_Big_Spit_body_entered(body):
	if body.name.find("Lizard_Boss") == -1:
		if body.name.find("Player") != -1:
			master_data.health -= master_data.lizard_spit_damage
			body._knockback(kb_dir, 2)
		$AnimatedSprite.play("pop")
		pop = true


func _on_AnimatedSprite_animation_finished():
	if pop:
		var slime = SLIME.instance()
		get_parent().add_child(slime)
		slime.position = $Position2D.global_position
		
		queue_free()
