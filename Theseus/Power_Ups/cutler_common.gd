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


func _on_cutler_common_body_entered(body):
	if body.name.find("Player") != -1:
		master_data.melee_multiplier = master_data.melee_multiplier + .07
		queue_free()
