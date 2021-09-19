extends Control


func _on_GhostBullet_pressed():
	$AudioStreamPlayer.play()
	yield($AudioStreamPlayer,"finished")	
	get_tree().change_scene("res://scenes/game.tscn")
	
