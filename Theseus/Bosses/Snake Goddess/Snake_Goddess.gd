extends KinematicBody2D


const DAMAGE = preload("res://Enemies/Snake/Snake_Dmg.tscn")
const POISON = preload("res://Enemies/Snake/Snake_Psn.tscn")
const SMOKE = preload("res://Bosses/Snake Goddess/FailSmoke.tscn")


var sleeping = true
var previous_animation = "statue"
var spawning = false
var can_be_damaged = false
var dead = false
var mad = false

#in the event all boxes for spawning snakes are filled.
var times_called = 0

var velocity = Vector2()
var speed = 0
var health = master_data.snake_goddess_health
var sees_player = false
var dir = "left"

func _ready():
	$Health_Bar.setMax(master_data.snake_goddess_health)
	$Health_Bar.setValue(master_data.snake_goddess_health)

func _physics_process(delta):
	#activate when the player gets close
	#if master_data.hypotnuse(get_parent().get_child(3).get_global_position(), get_global_position())<150 and sleeping:
	if position.x > master_data.player_x:
		dir = "left"
		$AnimatedSprite.flip_h = false
		
	if position.x < master_data.player_x:
		dir = "right"
		$AnimatedSprite.flip_h = true
		
	
	if master_data.hypotnuse(Vector2(master_data.player_global_x, master_data.player_global_y), get_global_position()) < 150 and sleeping:
		activate()
		
	#if player is 105 away go toward, if closer than 95 go away.
	if !sleeping and !spawning and !dead and !mad:
		
		if master_data.hypotnuse(get_parent().get_child(3).get_global_position(), get_global_position()) > 105:
			velocity = master_data.get_unit_vector(get_parent().get_child(3).get_global_position().x-get_global_position().x, get_parent().get_child(3).get_global_position().y-get_global_position().y)*speed
		elif master_data.hypotnuse(get_parent().get_child(3).get_global_position(), get_global_position()) < 95:
			velocity = master_data.get_unit_vector(get_parent().get_child(3).get_global_position().x-get_global_position().x, get_parent().get_child(3).get_global_position().y-get_global_position().y)*-speed
		else:
			velocity = Vector2(0,0)
		#print (velocity)
		velocity = move_and_slide(velocity)
		$AnimatedSprite.play("idle")
		
		#print($ProximityDetection.get_overlapping_bodies()[0].to_string())
		
	if !mad and !spawning and !dead:
		for thing in $ProximityDetection.get_overlapping_bodies():
			if thing.to_string().find("Player", 0) != -1:
				mad = true
				print("MAD")
				
		#stop and whack the player of too close.
		if mad:
			velocity = Vector2(0,0)
			whack()

func whack():
	print("WHACKED")
	$AnimatedSprite.play("whack")
	previous_animation = "whack"
	master_data.health -= master_data.snake_goddess_whack_damage
	get_parent().get_node("Player")._knockback(dir,8)

func damage(dmg):
	if can_be_damaged:
		health-=dmg
		$Health_Bar.setValue(health)
		#flash
	if health <= 0:
		dead = true
		$AnimatedSprite.play("death")
		previous_animation = "death"

func has_collision(body):
	print(body)
	var bodies = body.get_overlapping_bodies()
	#print(bodies.size())
	if bodies.size() == 0:
		#print("HEEHEEHEEHA")
		return false
	
	return true


func activate():
	#sleeping = false
	#can_be_damaged = true
	master_data.music = "boss"
	$AnimatedSprite.play("activate")
	previous_animation = "activate"
	
func spawn_snake(iterations):
	if !mad:
		var boxes = $Wall_Spacer.get_children()
		var pos = $Positions.get_children()
		
		var random = RandomNumberGenerator.new()
		
		random.randomize()
		var box = random.randi_range(0, 9)
		#print(box)
		random.randomize()
		var type = random.randi_range(0,1)
		#print(box)
		#print(times_called)
		
		spawning = true
		speed = 0
		$AnimatedSprite.play("summon")
		previous_animation = "summon"
		
		if !has_collision(boxes[box]):
			times_called = 0
			if type == 0:
				var damage = DAMAGE.instance()
				get_parent().get_node("Damage_Snakes").add_child(damage)
				damage.global_position = $Positions.get_children()[box].global_position
			else:
				print(get_parent().get_node("Poison_Snakes"))
				var poison = POISON.instance()
				get_parent().add_child(poison)
				poison.global_position = $Positions.get_children()[box].global_position
			print("YAY SNAKE")
		#recursively call until spawn annother snake 
		
		else:
			if iterations<24:
				print(iterations)
				spawn_snake(iterations+1)
			else:
				var smoke = SMOKE.instance()
				get_parent().add_child(smoke)
				smoke.global_position = self.position
				#times_called = 0
				print("SMOKE GRENADE")


func _on_AnimatedSprite_animation_finished():
	if previous_animation == "activate":
		can_be_damaged = true
		sleeping = false
		speed = 50
	if previous_animation == "summon":
		spawning = false
		speed = 50
		
	if previous_animation == "death":
		queue_free()
		
	if previous_animation == "whack":
		mad = false
		print("no more mad")


func _on_Spawn_Timer_timeout():
	#print ("do da spawn")
	if !sleeping and !dead:
		spawn_snake(times_called)
	

