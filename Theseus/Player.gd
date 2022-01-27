extends KinematicBody2D

const SPEED = 75
var velocity = Vector2()

func _physics_process(delta):
	if Input.is_action_pressed("ui_d"):
		$AnimatedSprite.flip_h = false
		velocity.x = SPEED
	
	if Input.is_action_pressed("ui_a"):
		$AnimatedSprite.flip_h = true
		velocity.x = -SPEED
		
	elif !Input.is_action_pressed("ui_a") and !Input.is_action_pressed("ui_d"):
		velocity.x = 0
		
	if Input.is_action_pressed("ui_w"):
		velocity.y = -SPEED
	
	if Input.is_action_pressed("ui_s"):
		velocity.y = SPEED
		
	elif !Input.is_action_pressed("ui_w") and !Input.is_action_pressed("ui_s"):
		velocity.y = 0
		
	velocity = move_and_slide(velocity)
