extends Position2D

# not technically an abstract class cuz not all the variables/methods have to be instantiated/declared, but it's close enough

onready var animated_sprite = get_parent().get_node("AnimatedSprite")

var can_see_player = false

"""

Required variables for each enemy:

var health = <info from master data>
var knockback = false
var is_frozen = false


Required misc stuff for each enemy:
	
	- having the main animated sprite called "AnimatedSprite"
	- having the flash shader on the AnimatedSprite
	- have an animation called "idle" in the AnimatedSprite object

"""

const DAMAGE_TEXT = preload("res://Misc/Damage_Text.tscn")

func _ready():
	var anim_frames = animated_sprite.frames
	var anim_frame_texture = anim_frames.get_frame("idle", 0)
	#$VisibilityNotifier2D.rect.x = anim_frame_texture.get_width()
	#$VisibilityNotifier2D.text.y = anim_frame_texture.get_height()
	

func _physics_process(delta):
	

	if can_see_player == true:
		pass

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
		animated_sprite.material.set_shader_param("flash_modifier", 0.75)
		animated_sprite.material.set_shader_param("flash_color", master_data.colors["light_blue"])
		$frozen_timer.start(master_data.freeze_time)
	else:
		animated_sprite.material.set_shader_param("flash_modifier", 1)
		animated_sprite.material.set_shader_param("flash_color", master_data.colors["white"])
		$flash_timer.start(master_data.flash_time)


func _on_flash_timer_timeout():
	animated_sprite.material.set_shader_param("flash_modifier", 0)


func _on_knockback_timer_timeout():
	get_parent().knockback = false


func _on_VisibilityNotifier2D_screen_entered():
	can_see_player = true


func _on_VisibilityNotifier2D_screen_exited():
	can_see_player = false


func _on_frozen_timer_timeout():
	animated_sprite.material.set_shader_param("flash_modifier", 0)
	get_parent().is_frozen = false
