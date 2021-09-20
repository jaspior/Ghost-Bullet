extends Control

enum{left,right}
var rot = left

func _process(delta):
	if rot == left: 
		if $GhostBullet.rect_rotation >= -25:
			$GhostBullet.rect_rotation -= .3 
		else:
			rot = right
	elif rot == right:
		if $GhostBullet.rect_rotation <= 24:
			$GhostBullet.rect_rotation += .3
		else:
			rot = left
			

func _on_GhostBullet_pressed():
	$AudioStreamPlayer.play()
	yield($AudioStreamPlayer,"finished")	
	get_tree().change_scene("res://scenes/game.tscn")
	


func _on_blink_timer_timeout():
	if $Press_right_click.modulate.a == 1:
		$Press_right_click.modulate.a = 0
	else:
		$Press_right_click.modulate.a = 1
