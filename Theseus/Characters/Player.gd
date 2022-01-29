extends KinematicBody2D


# velocity is the player's movement
var velocity = Vector2()

# used to make sure the player can only attack again after the previous attack is finished
var sword_swinging = false

var direction = "right"

func _physics_process(delta):
	
	var speed = master_data.player_speed
	
	# update the master_data values
	master_data.player_x = position.x
	master_data.player_y = position.y
	
	# movement logic
	if Input.is_action_pressed("ui_d") and !Input.is_action_pressed("ui_a"):
		direction = "right"
		$CharacterAnimatedSprite.play("run_right")
		velocity.x = speed * delta
	
	if Input.is_action_pressed("ui_a") and !Input.is_action_pressed("ui_d"):
		direction = "left"
		$CharacterAnimatedSprite.play("run_left")
		velocity.x = -speed * delta
		
	elif !Input.is_action_pressed("ui_a") and !Input.is_action_pressed("ui_d"):
		velocity.x = 0
		
	# horizontal animiations take priority over vertical animations
	if Input.is_action_pressed("ui_w"):
		if !Input.is_action_pressed("ui_a") and !Input.is_action_pressed("ui_d"):
			$CharacterAnimatedSprite.play("run_up")
			direction = "up"
		velocity.y = -speed * delta
	
	if Input.is_action_pressed("ui_s"):
		if !Input.is_action_pressed("ui_a") and !Input.is_action_pressed("ui_d"):
			$CharacterAnimatedSprite.play("run_down")
			direction = "down"
		velocity.y = speed * delta
		
	elif !Input.is_action_pressed("ui_w") and !Input.is_action_pressed("ui_s"):
		velocity.y = 0
	
	if !Input.is_action_pressed("ui_d") and !Input.is_action_pressed("ui_a"):
		if !Input.is_action_pressed("ui_w") and !Input.is_action_pressed("ui_s"):
			if direction == "right":
				$CharacterAnimatedSprite.play("idle_right")
			if direction == "left":
				$CharacterAnimatedSprite.play("idle_left")
			if direction == "up":
				$CharacterAnimatedSprite.play("idle_up")
			if direction == "down":
				$CharacterAnimatedSprite.play("idle_down")
		
	if Input.is_action_pressed("ui_x") and !sword_swinging:
		sword_swinging = true
		$SwordAnimation.visible = true
		if direction == "down":
			$SwordAnimation.play("down")
		if direction == "up":
			$SwordAnimation.play("up")
		if direction == "left":
			$SwordAnimation.play("left")
		if direction == "right":
			$SwordAnimation.play("right")
	
	if $SwordAnimation.is_playing():
		# will put code here to damage enemies
		pass
		
	velocity = move_and_slide(velocity)


func _on_SwordAnimation_animation_finished():
	sword_swinging = false
	$SwordAnimation.playing = false
	$SwordAnimation.visible = false
