extends Node2D

func activate(txt):
	$Label.text = "-" + str(txt)
	$Label.visible = true
	$Timer.start(master_data.damage_text_time)

func _on_Timer_timeout():
	$Label.visible = false
