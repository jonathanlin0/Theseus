extends Node2D

const IMPLOSION = preload("res://Particle_Effects/Implosion.tscn")
const SMALL_SLIME = preload("res://Enemies/Slime/Small_Slime.tscn")

var temp = []

func _ready():
	Server.fetch_test_data()

func _process(delta):
	pass
