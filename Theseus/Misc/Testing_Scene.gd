extends Node2D

const IMPLOSION = preload("res://Particle_Effects/Implosion.tscn")
const SMALL_SLIME = preload("res://Enemies/Slime/Small_Slime.tscn")
var cursor = load("res://Misc/Sprites/cursor_cross.png")

var temp = []

func _ready():
	Input.set_custom_mouse_cursor(cursor)
	
	

func _process(delta):
	pass
