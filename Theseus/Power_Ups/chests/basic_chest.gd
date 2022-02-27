extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var net_distance
var last_anim

var powOne
var powTwo

var rare_chance = master_data.rare_chance_in_basic_chest
var rand = RandomNumberGenerator.new()

var opened = false


const CUTLER_COMMON = preload("res://Power_Ups/cutler_common.tscn")
const CUTLER_RARE = preload("res://Power_Ups/cutler_rare.tscn")
const HEALTH_COMMON = preload("res://Power_Ups/healthcanister_common.tscn")
const HEALTH_RARE = preload("res://Power_Ups/healthcanister_rare.tscn")
const MANA_COMMON = preload("res://Power_Ups/manacanister_common.tscn")
const MANA_RARE = preload("res://Power_Ups/manacanister_rare.tscn")
const EYE_COMMON = preload("res://Power_Ups/rangedeye_common.tscn")
const EYE_RARE = preload("res://Power_Ups/rangedeye_rare.tscn")
const WINGS_COMMON = preload("res://Power_Ups/wings_common.tscn")
const WINGS_RARE = preload("res://Power_Ups/wings_rare.tscn")

var pow_array_common = [CUTLER_COMMON, HEALTH_COMMON, MANA_COMMON, EYE_COMMON, WINGS_COMMON]
var pow_array_rare = [CUTLER_RARE, HEALTH_RARE, MANA_RARE, EYE_RARE, WINGS_RARE]

# Called when the node enters the scene tree for the first time.
func _ready():
	rand.randomize()
	var rand_num = rand.randf_range(0, 1.0)
	
	if (rand_num <= rare_chance):
		powOne = (pow_array_rare[randi() % pow_array_rare.size()]).instance()
	else:
		powOne = (pow_array_common[randi() % pow_array_common.size()]).instance()
		
	rand.randomize()
	rand_num = rand.randf_range(0, 1.0)
	
	if (rand_num <= rare_chance):
		powTwo = (pow_array_rare[randi() % pow_array_rare.size()]).instance()
	else:
		powTwo = (pow_array_common[randi() % pow_array_common.size()]).instance()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var difference_x = master_data.player_x - global_position.x
	var difference_y = master_data.player_y - global_position.y
	
	net_distance = sqrt((difference_x * difference_x) + (difference_y * difference_y))
	
	if (net_distance <= master_data.chest_distance && !opened or Input.is_action_just_pressed("ui_up")):
		if (Input.is_action_just_pressed("ui_accept")):
			$AnimatedSprite.play("opening")
			last_anim = "opening"
			



func _on_AnimatedSprite_animation_finished():
	if (last_anim == "opening" && !opened):
		$AnimatedSprite.play("opened")
		last_anim = "opened"
		get_parent().add_child(powOne)
		powOne.global_position = $powPosOne.global_position
		powOne.direction = 1
		get_parent().add_child(powTwo)
		powTwo.global_position = $powPosTwo.global_position
		powTwo.direction = -1
		opened = true
		
