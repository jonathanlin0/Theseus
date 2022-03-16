extends StaticBody2D


var net_distance

func _ready():
	pass

func _process(delta):
	var difference_x = master_data.player_x - position.x
	var difference_y = master_data.player_y - position.y
	net_distance = sqrt((difference_x * difference_x) + (difference_y * difference_y))
	
	if net_distance < master_data.sign_distance:
		if Input.is_action_just_pressed("ui_accept"):
			$guide_three.position.x = $Sprite.position.x
			$guide_three.position.y = $Sprite.position.y
			$guide_three.visible = true
	else:
		$guide_three.visible = false
