extends KinematicBody2D

const SPEED = 75
var velocity = Vector2()

func _physics_process(delta):
	if Input.is_action_pressed("ui_d"):
		$AnimatedSprite.play("run_right")
		velocity.x = SPEED
	
	if Input.is_action_pressed("ui_a"):
		$AnimatedSprite.play("run_left")
		velocity.x = -SPEED
		
	elif !Input.is_action_pressed("ui_a") and !Input.is_action_pressed("ui_d"):
		velocity.x = 0
		
	if Input.is_action_pressed("ui_w"):
		if !Input.is_action_pressed("ui_a") and !Input.is_action_pressed("ui_d"):
			$AnimatedSprite.play("run_up")
		velocity.y = -SPEED
	
	if Input.is_action_pressed("ui_s"):
		if !Input.is_action_pressed("ui_a") and !Input.is_action_pressed("ui_d"):
			$AnimatedSprite.play("run_down")
		velocity.y = SPEED
		
	elif !Input.is_action_pressed("ui_w") and !Input.is_action_pressed("ui_s"):
		velocity.y = 0
		
	velocity = move_and_slide(velocity)
