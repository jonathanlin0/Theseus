extends Position2D

"""

Required variables for each enemy:
	
var health = <info from master data>
var knockback = false


Required misc stuff for each enemy:
	
	- having the main animated sprite called "AnimatedSprite"
	- having the flash shader on the AnimatedSprite

"""

const DAMAGE_TEXT = preload("res://Misc/Damage_Text.tscn")

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
	get_parent().get_node("AnimatedSprite").material.set_shader_param("flash_modifier", 1)
	$flash_timer.start(master_data.flash_time)


func _on_flash_timer_timeout():
	get_parent().get_node("AnimatedSprite").material.set_shader_param("flash_modifier", 0)


func _on_knockback_timer_timeout():
	get_parent().knockback = false
