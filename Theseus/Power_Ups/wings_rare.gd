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


func _on_wings_rare_body_entered(body):
	if body.name.find("Player") != -1 and master_data.player_speed < 10000:
		master_data.player_speed = master_data.player_speed + 400
		queue_free()
