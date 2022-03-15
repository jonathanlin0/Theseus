extends KinematicBody2D

var attacking = false
var previous_animation = "slither"

var can_player_take_damage = true

func _physics_process(delta):
	
	for obj in $damage_area.get_overlapping_bodies():
		if obj.name.find("Player") != -1 and previous_animation != "attack":
			#attacking = true
			previous_animation = "charge_up"
			$AnimatedSprite.play("charge_up")
	
	if $AnimatedSprite.animation == "attack" and can_player_take_damage == true:
		master_data.health -= master_data.snake_dmg_damage
		can_player_take_damage = false



func _on_AnimatedSprite_animation_finished():
	if previous_animation == "charge_up":
		previous_animation = "attack"
		$AnimatedSprite.play("attack")
	elif previous_animation == "attack":
		previous_animation = "slither"
		$AnimatedSprite.play("slither")
		can_player_take_damage = true
