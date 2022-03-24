extends Node2D

var num_green = (master_data.slimes_def * 0.2) + (master_data.lizards_def * 0.5) + 1
var num_red = (master_data.snakes_def) + 1
var num_gold = (master_data.chimeras_def) + 1

const GREEN = preload("res://Enemies/Spirits/Green_Spirit.tscn")
const RED = preload("res://Enemies/Spirits/Red_Spirit.tscn")
const GOLD = preload("res://Enemies/Spirits/Gold_Spirit.tscn")

var x_lower = -1400
var x_upper = -200

var y_lower = 50
var y_upper = 250

var rand = RandomNumberGenerator.new()

func _ready():
	master_data.music = "boss"
	rand.randomize()
	for n in num_green:
		var x_cood = rand.randf_range(x_lower, x_upper)
		var y_cood = rand.randf_range(y_lower, y_upper)
		var grn = GREEN.instance()
		grn.position.x = x_cood
		grn.position.y = y_cood
		add_child(grn)
	for n in num_red:
		var x_cood = rand.randf_range(x_lower, x_upper)
		var y_cood = rand.randf_range(y_lower, y_upper)
		var re = RED.instance()
		re.position.x = x_cood
		re.position.y = y_cood
		add_child(re)
	for n in num_gold:
		var x_cood = rand.randf_range(x_lower, x_upper)
		var y_cood = rand.randf_range(y_lower, y_upper)
		var go = GOLD.instance()
		go.position.x = x_cood
		go.position.y = y_cood
		add_child(go)

func _process(delta):

	if Input.is_action_just_pressed("ui_n"):
		master_data.end_time = OS.get_unix_time()
		
		# only for testing
		get_tree().change_scene("res://Misc/Leaderboard.tscn")
