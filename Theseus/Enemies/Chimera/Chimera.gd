extends KinematicBody2D

var velocity = Vector2()

var triggered = false
var dir = "left"

var moving = false

var rand = RandomNumberGenerator.new()
var rand_x_vel = 0
var rand_y_vel = 0

var health = master_data.chimera_health

var is_dead = false

var can_attack = true

var prev_anim = ""

var knockback = false
var collision

var lion_attack = false
var goat_attack = false

var attacking = false

func _randomize():
	if triggered:
		rand.randomize()
		rand_x_vel = rand.randf_range(-100, 100)
		rand_y_vel = rand.randf_range(-30, 30)
		velocity.x += rand_x_vel
		velocity.y += rand_y_vel
		
		if velocity.x > 50:
			velocity.x = 50
		
		if velocity.x < -50:
			velocity.x = -50
		
		if velocity.y > 20:
			velocity.y = 20
		
		if velocity.y < -20:
			velocity.y = -20

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("idle")
	prev_anim = "idle"
	$Health_Bar.setMax(master_data.chimera_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(prev_anim)
	$Health_Bar.setValue(health)
	if health <= 0:
		dead()
		
	if is_dead == false:
		if velocity.x != 0:
			moving = true
		if velocity.x == 0:
			moving = false
		# used for player tracking
		
		collision = move_and_collide(velocity * delta)
		if collision:
			velocity = velocity.bounce(collision.normal)
			_randomize()

func dead():
	$AnimatedSprite.play("death")
	$CollisionShape2D.disabled = true
	is_dead = true

func damage(dmg):
	triggered = true
	_randomize()
	health -= dmg

var done_charging = false
func _on_AnimatedSprite_animation_finished():
	if moving:
		$AnimatedSprite.play("walk")
		prev_anim = "walk"
	if !moving && !attacking:
		$AnimatedSprite.play("idle")
		prev_anim = "idle"
	if lion_attack:
		$AnimatedSprite.play("lion_chargeup")
		prev_anim = "lion_chargeup"
		attacking = true
		done_charging = false
	if lion_attack && attacking && !done_charging:
		done_charging = true
	if lion_attack && done_charging:
		$AnimatedSprite.play("lion_attack")
	if is_dead:
		queue_free()


func _on_lion_box_body_entered(body):
	if body.name.find("Player") != -1:
		velocity.x = 0
		velocity.y = 0
		lion_attack = true
		goat_attack = false
		$attack.start()


func _on_goat_box_body_entered(body):
	if body.name.find("Player") != -1:
		velocity.x = 0
		velocity.y = 0
		lion_attack = false
		goat_attack = true
		$attack.start()


func _on_attack_timeout():
	attacking = false
	_randomize()


func _on_lion_box_body_exited(body):
	if body.name.find("Player") != -1:
		lion_attack = false
		goat_attack = false
		attacking = false


func _on_goat_box_body_exited(body):
	if body.name.find("Player") != -1:
		lion_attack = false
		goat_attack = false
		attacking = false
