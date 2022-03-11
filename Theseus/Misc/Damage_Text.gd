extends Position2D

# good youtube tutorial for floating damage text:
# https://youtu.be/UlvBqz8bhCo

onready var label = get_node("Label")
onready var tween = get_node("Tween")
var amount = 0

var velocity = Vector2(0,0)

# in degrees, the total angle from the normal line left and right that the text will pop up
# so if angle_of_popup = 10, then it would be a total angle range of 20
var angle_of_popup = 40

# speed in which the text goes
# faster the text, the farther it will go upward
var text_speed = 25

var beginning_scale = 0.7

var max_scale = 1.6

func _ready():
	
	scale = Vector2(beginning_scale, beginning_scale)
	
	label.set_text(str(amount))
	
	randomize()
	var side_movement = randi() % (angle_of_popup * 2 + 1) - angle_of_popup
	velocity = Vector2(side_movement, text_speed)
	
	# grows in size, then shrinks again before disappearing
	tween.interpolate_property(self, "scale", scale, Vector2(max_scale,max_scale), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, "scale", Vector2(max_scale,max_scale), Vector2(0.1, 0.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
	tween.start()

func _process(delta):
	position -= velocity * delta

"""
func activate(txt):
	$Label.text = "-" + str(txt)
	visible = true
	$Timer.start(master_data.damage_text_time)

func _on_Timer_timeout():
	visible = false
"""


func _on_Tween_tween_all_completed():
	self.queue_free()
