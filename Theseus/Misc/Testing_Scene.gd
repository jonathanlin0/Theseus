extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	master_data.level = 0

func _process(delta):
	if Input.is_action_pressed("ui_w") and $Damage_Text.visible == true:
		$Damage_Text/Timer.start()

func _on_Timer_timeout():
	$Damage_Text/Small_Slime.damage(3)
	$Damage_Text/Timer.start()
