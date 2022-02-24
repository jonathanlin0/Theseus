extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	if body.name.find("Player") != -1:
		
		if (master_data.health < master_data.max_health):
			master_data.health = master_data.health + 100
			if (master_data.health > master_data.max_health):
				master_data.health = master_data.max_health
			queue_free()
		else:
			master_data.max_health = master_data.max_health + 20
			master_data.health = master_data.max_health
			queue_free()
