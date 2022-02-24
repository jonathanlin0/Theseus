extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var net_distance
var last_anim

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var difference_x = master_data.player_x - position.x
	var difference_y = master_data.player_y - position.y
	
	net_distance = sqrt((difference_x * difference_x) + (difference_y * difference_y))
	
	if (net_distance <= master_data.chest_distance):
		if (Input.is_action_just_pressed("ui_up")):
			$AnimatedSprite.play("opening")
			last_anim = "opening"


func _on_AnimatedSprite_animation_finished():
	if (last_anim == "opening"):
		$AnimatedSprite.play("opened")
