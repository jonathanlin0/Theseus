extends Area2D

var active = false;

var original_melee = master_data.sword_damage
var original_ranged = master_data.fireball_damage

func _on_Node2D_body_entered(body):
	if body.name.find("Player") != -1 and active == false:
		master_data.sword_damage = master_data.sword_damage*1.1
		master_data.fireball_damage = master_data.fireball_damage*1.1
		active == true
		$Timer.start()
		self.visible = false
		


func _on_Timer_timeout():
	master_data.sword_damage = original_melee
	master_data.fireball_damage = original_ranged
	queue_free()
