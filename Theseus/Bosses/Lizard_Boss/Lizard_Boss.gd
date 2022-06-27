extends KinematicBody2D

var velocity = Vector2()

var prev_anim = "idle"
var triggered = false

var in_slap_range = false

var attack_cooldown = false
var spit_cooldown = false

var health = master_data.lizard_boss_health

var dead = false

var player

var rand = RandomNumberGenerator.new()
var rand_x_vel = 20
var rand_y_vel = 20
var dir = "left"

var moving = false

var sees_player = false

var regen = true

var is_frozen = false

const SPIT = preload("res://Bosses/Lizard_Boss/Big_Spit.tscn")
const BOSS_GATE = preload("res://Bosses/boss_gate.tscn")
const STAIRS = preload("res://Bosses/stairs.tscn")
const SIGN_FIVE = preload("res://Misc/Signs/sign_five.tscn")

const DAMAGE_TEXT = preload("res://Misc/Damage_Text.tscn")

const CHEST = preload("res://Power_Ups/Chests/rare_chest.tscn")

func _randomize():
	if triggered:
		rand.randomize()
		rand_x_vel = rand.randf_range(-100, 100)
		rand_y_vel = rand.randf_range(-40, 40)
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
	$Health_Bar.setMax(master_data.lizard_boss_health)

func _physics_process(delta):
	
	if !triggered:
		if master_data.player_x > 2346:
			trigger()
	
	if regen:
		health += 0.5
	if health > master_data.lizard_boss_health:
		health = master_data.lizard_boss_health
	$Health_Bar.setValue(health)
	if health <= 0:
		dead = true
	if !dead and !is_frozen:
		var difference_x = master_data.player_x - position.x
		var difference_y = master_data.player_y - position.y
		var net_distance = 0
		net_distance = sqrt((difference_x * difference_x) + (difference_y * difference_y))
		var collision = move_and_collide(velocity * delta)
		if difference_x < 0:
			dir = "left"
		if difference_x > 0:
			dir = "right"
		if dir == "left":
			scale.x = scale.y * 1
			$Health_Bar.set_rotation(0)
		if dir == "right":
			scale.x = scale.y * -1
			$Health_Bar.set_rotation(3.14159)
		if !moving:
			velocity.x = 0
			velocity.y = 0
		if collision:
			velocity = velocity.bounce(collision.normal)
			_randomize()
		if moving && !dead:
			$AnimatedSprite.play("walk")
		if net_distance <= master_data.small_lizard_attack_range * 1.5 && !spit_cooldown && !dead:
			$AnimatedSprite.play("spit")
			moving = false
			prev_anim = "spit"
			$spit_attack.start()
			spit_cooldown = true
			trigger()
			_randomize()

func trigger():
	if !triggered:
		master_data.music = "boss"
		triggered = true
		var block = BOSS_GATE.instance()
		block.position.x = 2320
		block.position.y = 224
		get_parent().add_child(block)

func damage(dmg):
	if !dead && triggered:
		$regen.start()
		health -= dmg
		regen = false
		$Enemy_Abstract_Class.flash()
		$Enemy_Abstract_Class.damage_text(dmg)
		$Enemy_Abstract_Class.damage_audio()
		_randomize()
	if health <= 0:
		moving = false
		triggered = false
		in_slap_range = false
		dead = true
		$AnimatedSprite.play("death")
		prev_anim = "death"
		

func flash():
	$AnimatedSprite.material.set_shader_param("flash_modifier", 1)
	$flash_timer.start(master_data.flash_time)

func _on_slap_body_entered(body):
	if body.name.find("Player") != -1:
		player = body
		in_slap_range = true


func _on_AnimatedSprite_animation_finished():
	
	if dead:
		var chest = CHEST.instance()
		chest.position = $chestpos.global_position
		get_parent().add_child(chest)
		var sign_five = SIGN_FIVE.instance()
		sign_five.position.x = 2649
		sign_five.position.y = 340
		get_parent().add_child(sign_five)
		var next = STAIRS.instance()
		next._set_destination("stage_two")
		master_data.level = 2
		next.position.x = 2759
		next.position.y = 341
		get_parent().add_child(next)
		queue_free()
	if !dead && health > 0:
		if prev_anim == "slap":
			if moving:
				$AnimatedSprite.play("walk")
				prev_anim = "walk"
			else:
				$AnimatedSprite.play("idle")
				prev_anim = "idle"
		
		if prev_anim == "idle" && moving:
			$AnimatedSprite.play("walk")
		
		if prev_anim == "spit":
			moving = false
			var spit = SPIT.instance()
			spit.kb_dir = dir
			get_parent().add_child(spit)
			spit.position = $spitpos.global_position
			spit.set_coords(position.x, position.y)
			prev_anim = "idle"
		
		if in_slap_range && !attack_cooldown:
			moving = false
			$AnimatedSprite.play("slap")
			prev_anim = "slap"
			master_data.health -= master_data.lizard_boss_slap_damage
			player._knockback(dir, 5)
			$attack.start()
			attack_cooldown = true
		elif !in_slap_range:
			$AnimatedSprite.play("idle")
			prev_anim = "idle"
			if triggered:
				moving = true
				_randomize()
		
		if in_slap_range && prev_anim == "idle":
			$AnimatedSprite.play("windup")
			prev_anim = "windup"
		
	

func _on_slap_body_exited(body):
	in_slap_range = false


func _on_attack_timeout():
	attack_cooldown = false


func _on_spit_attack_timeout():
	spit_cooldown = false


func _on_regen_timeout():
	regen = true


func _on_flash_timer_timeout():
	$AnimatedSprite.material.set_shader_param("flash_modifier", 0)
