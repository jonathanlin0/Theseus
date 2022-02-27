extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var bouncing = true
var direction = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()

# 1 is right, -1 is left
func _set_direction(var dir):
	direction = dir

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if bouncing:
		position += transform.y * 600 * delta * (($Timer.wait_time / 2) - $Timer.time_left)
		position += transform.x * 50 * delta * direction


func _on_cutler_common_body_entered(body):
	if body.name.find("Player") != -1:
		master_data.melee_multiplier = master_data.melee_multiplier + .07
		bouncing = false
		queue_free()


func _on_Timer_timeout():
	bouncing = false
