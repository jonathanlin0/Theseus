extends KinematicBody2D

var health = master_data.chimera_health
var knockback = false
var is_frozen = false
var sees_player = false

var velocity = Vector2()

var triggered = false
var dir = "left"

var moving = false

var rand = RandomNumberGenerator.new()
var rand_x_vel = 0
var rand_y_vel = 0

var is_dead = false

var can_attack = true

var prev_anim = ""

var collision

var lion_attack = false
var goat_attack = false

var attacking = false

func _randomize():
	if triggered:
		rand.randomize()
		rand_x_vel = rand.randf_range(-60, 60)
		rand_y_vel = rand.randf_range(-30, 30)
		velocity.x += rand_x_vel
		velocity.y += rand_y_vel
		
		if velocity.x > 60:
			velocity.x = 60
		
		if velocity.x < -60:
			velocity.x = -60
		
		if velocity.y > 30:
			velocity.y = 30
		
		if velocity.y < -30:
			velocity.y = -30

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("idle")
	prev_anim = "idle"
	$Health_Bar.setMax(master_data.chimera_health)

var attack_time_started = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Enemy_Abstract_Class.on_screen:
		$Health_Bar.setValue(health)
		if health <= 0:
			dead()
			
		if is_dead == false and is_frozen == false:
			
			if velocity.x != 0:
				moving = true
			if velocity.x == 0:
				moving = false
			# used for player tracking
			
			if prev_anim == "lion_attack":
				if !attack_time_started:
					$lion_attack.start()
					attack_time_started = true
				position += transform.x * 1500 * delta * (($lion_attack.wait_time / 2) - ($lion_attack.time_left))
			
			if prev_anim == "goat_attack":
				if !attack_time_started:
					$goat_attack.start()
					attack_time_started = true
				position += transform.x * -2000 * delta * (($goat_attack.wait_time / 2) - ($goat_attack.time_left))
			
			collision = move_and_collide(velocity * delta)
			if collision && moving:
				velocity = velocity.bounce(collision.normal)
				_randomize()

func dead():
	$AnimatedSprite.play("death")
	$CollisionShape2D.disabled = true
	is_dead = true

func damage(dmg):
	triggered = true
	#_randomize()
	health -= dmg
	$Enemy_Abstract_Class.knockback()
	$Enemy_Abstract_Class.flash()
	$Enemy_Abstract_Class.damage_text(dmg)
	$Enemy_Abstract_Class.damage_audio()

func _on_AnimatedSprite_animation_finished():
	if is_dead:
		master_data.endless_mob_deaths.append(get_instance_id())
		queue_free()
	if is_frozen == false:
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
			$lion_charge.start()
		if goat_attack:
			$AnimatedSprite.play("goat_chargeup")
			prev_anim = "goat_chargeup"
			attacking = true
			$goat_charge.start()
	if is_frozen == true:
		$AnimatedSprite.play("frozen")
	


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
	if !triggered:
			triggered = true
			_randomize()
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


func _on_lion_charge_timeout():
	if lion_attack:
		$AnimatedSprite.play("lion_attack")
		prev_anim = "lion_attack"
	

func _on_goat_charge_timeout():
	if goat_attack:
		$AnimatedSprite.play("goat_attack")
		prev_anim = "goat_attack"


func _on_lion_attack_timeout():
	attack_time_started = false


func _on_goat_attack_timeout():
	attack_time_started = false


func _on_bump_area_body_entered(body):
	if prev_anim == "lion_attack" && body.name.find("Player") != -1:
		master_data.health = master_data.health - master_data.chimera_lion_damage
		body._knockback("left", 5)
	if prev_anim == "goat_attack" && body.name.find("Player") != -1:
		master_data.health = master_data.health - master_data.chimera_goat_damage
		body._knockback("right", 7)
