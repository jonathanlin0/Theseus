extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var difference_x = master_data.player_x - position.x
	var difference_y = master_data.player_y - position.y
	var net_distance = sqrt((difference_x * difference_x) + (difference_y * difference_y))
	
	if net_distance < master_data.sign_distance:
		if Input.is_action_just_pressed("ui_accept"):
			$guide_four.position.x = $Sprite.position.x
			$guide_four.position.y = $Sprite.position.y
			$guide_four.visible = true
	else:
		$guide_four.visible = false
