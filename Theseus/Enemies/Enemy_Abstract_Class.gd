extends Position2D

# not technically an abstract class cuz not all the variables/methods have to be instantiated/declared, but it's close enough

onready var animated_sprite = get_parent().get_node("AnimatedSprite")

var on_screen = false

"""

Required variables for each enemy:

var health = <info from master data>
var knockback = false
var is_frozen = false
var sees_player = false


Required misc stuff for each enemy:
	
	- having the main animated sprite called "AnimatedSprite"
	- having the flash shader on the AnimatedSprite
	- have an animation called "idle" in the AnimatedSprite object
	- have an animation called "idle" in the AnimatedSprite object

"""

const DAMAGE_TEXT = preload("res://Misc/Damage_Text.tscn")

func _ready():
	var anim_frames = animated_sprite.frames
	var anim_frame_texture = anim_frames.get_frame("idle", 0)
	#$VisibilityNotifier2D.rect.x = anim_frame_texture.get_width()
	#$VisibilityNotifier2D.text.y = anim_frame_texture.get_height()
	

func _physics_process(delta):
	if get_parent().is_frozen == true:
		animated_sprite.material.set_shader_param("flash_modifier", 0.75)
	#print(animated_sprite.material.get_shader_param("flash_modifier"))

# function for knockback
func knockback():
	# code for knockback has to be set up in the enemy's code
	
	$knockback_timer.start()
	get_parent().knockback = true


# play the damage audio
func damage_audio():
	$AudioStreamPlayer.play()


# show the damage text (a red text flying out in a random direction indicating how much damage the player just did to the enemy)
func damage_text(dmg):
	var text = DAMAGE_TEXT.instance()
	text.amount = dmg
	get_parent().add_child(text)


# the enemy flashes for a split second to indicate that the player did damage
func flash():
	if get_parent().is_frozen == true:
		animated_sprite.material.set_shader_param("flash_color", master_data.colors["light_blue"])
		animated_sprite.material.set_shader_param("flash_modifier", 0.75)
		
		$frozen_timer.start(master_data.freeze_time)
		print("freeze")
	else:
		animated_sprite.material.set_shader_param("flash_modifier", 1)
		animated_sprite.material.set_shader_param("flash_color", master_data.colors["white"])
		$flash_timer.start(master_data.flash_time)
		print("dmg")


func _on_flash_timer_timeout():
	# there's a bug where if the player damages the enemy with fireball or lightning and then tries to freeze the enemy, the enemy will flash blue but will not stay blue while frozen like intended
	# this condition somehow fixes the bug, but I don't know why. but it seems like this conditional statement works and doesn't break anything, so we're going to roll with it
	# - jonathan :D
	if get_parent().is_frozen == false:
		animated_sprite.material.set_shader_param("flash_modifier", 0)


func _on_knockback_timer_timeout():
	get_parent().knockback = false


func _on_VisibilityNotifier2D_screen_entered():
	on_screen = true


func _on_VisibilityNotifier2D_screen_exited():
	on_screen = false


func _on_frozen_timer_timeout():
	
	animated_sprite.material.set_shader_param("flash_modifier", 0)
	get_parent().is_frozen = false
