extends Node2D

const IMPLOSION = preload("res://Particle_Effects/Implosion.tscn")
const SMALL_SLIME = preload("res://Enemies/Slime/Small_Slime.tscn")

var temp = []

func _ready():
	var implosion = IMPLOSION.instance()
	implosion.scale.x = 0.07
	implosion.scale.y = 0.07
	add_child(implosion)
	implosion.global_position = Vector2(240,135)
	temp.append(implosion)
	$Timer.start(1)

func _process(delta):
	pass


func _on_Timer_timeout():
	pass
