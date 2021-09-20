extends Node2D


enum{alive,dead,shot}
var health = alive 

enum{low,lift}
var status = low

enum{pos1,pos2,pos3,pos4}
var ghost = pos1 

enum{caffe,rain,spooky}
var animation = caffe

enum{hide,on_screen}
var ghost_status = hide

var points = 1000
var player_name = "Nameless"

func _ready():
	$anim.play("start")
	yield($anim,"animation_finished")

func _process(delta):
	shoot()
	$Label.text = str(points)

func _on_timer_animation_timeout():
	var rand
	if animation == caffe:
		$Animation/Animated_caffe.show()
		$Animation/Animated_rain.hide()
		rand = rand_range(0,100)
		if rand >= 30:
			animation = rain
		else: 
			animation = spooky
		
	elif animation == rain:
		$Animation/Animated_caffe.hide()
		$Animation/Animated_rain.show()
		rand = rand_range(0,100)
		if rand >= 30:
			animation = caffe
		else: 
			animation = spooky

	elif animation == spooky:
		$Timers/ghost_hide.wait_time = .4 + .5*ghost
		$Timers/points_timer.start()
		ghost_transition()
		ghost_status = on_screen
		$Press_space.show()
		$SFX/ghost.play()
		if ghost <= pos4:
			$Timers/ghost_hide.start()
		animation = rain

func _on_timer_lights_timeout():
	$room_light.energy = rand_range(0 , .2)
	$screen_light.energy = rand_range(0 , .5)

func _on_timer_arms_timeout():
	if status == low:
		$arms_and_hands/arms.position.y += 1
		if $arms_and_hands/arms.position.y >= 510:
			status = lift
					
	elif status == lift:
		$arms_and_hands/arms.position.y -= 1
		if $arms_and_hands/arms.position.y <= 490:
			status = low
			
func ghost_transition():
	if ghost == pos1:
		$Ghosts/ghost_128.show()
		$Ghosts/Ghost_256.hide()
		$Ghosts/Ghost_360.hide()
		$Ghosts/Ghost_close.hide()
		#ghost = pos2
		
	elif ghost == pos2:
		$Ghosts/ghost_128.hide()
		$Ghosts/Ghost_256.show()
		$Ghosts/Ghost_360.hide()
		$Ghosts/Ghost_close.hide()

	elif ghost == pos3:
		$Ghosts/ghost_128.hide()
		$Ghosts/Ghost_256.hide()
		$Ghosts/Ghost_360.show()
		$Ghosts/Ghost_close.hide()
		
	elif ghost == pos4:
		$Ghosts/ghost_128.hide()
		$Ghosts/Ghost_256.hide()
		$Ghosts/Ghost_360.hide()
		$Ghosts/Ghost_close.show()
		$Timers/ghost_hide.stop()
		$Timers/timer_animation.stop()
		$Timers/timer_arms.stop()
	
	ghost += 1
	


func _on_ghost_hide_timeout():
	ghost_status = hide
	$Ghosts/ghost_128.hide()
	$Ghosts/Ghost_256.hide()
	$Ghosts/Ghost_360.hide()
	$Ghosts/Ghost_close.hide()
	$Timers/points_timer.stop()
	$Press_space.hide()


func _on_points_timer_timeout():
	points -= 15
	if points <= 0:
		health = dead 
		$Timers/points_timer.stop()
		$anim.play("die")
		yield($anim,"animation_finished")
		points = 0 
		get_tree().reload_current_scene()
		#$Leaderboard/Control/PopupPanel.popup_centered()


func shoot():
	if health == alive:
		if Input.is_action_just_pressed("shoot"):
			$Timers/ghost_hide.stop()
			$Timers/points_timer.stop()
			$Timers/timer_animation.stop()
			$Timers/timer_arms.stop()
			$anim.play("shoot")
			yield($anim,"animation_finished")
				
			if ghost_status == hide:
				points = 0
			elif ghost_status == on_screen:
				points = points
			
			health = shot
			
			if points > 0:
				$Leaderboard/Control/MarginContainer/PopupPanel.popup_centered()
			else:
				get_tree().reload_current_scene()

func _on_text_timers_timeout():
	var random = randi()%4+1
	if random == 1:
		$texts_anim.play("event1")
	elif random == 2:
		$texts_anim.play("event2")
	elif random == 3:
		$texts_anim.play("event3")
	elif random == 4:
		$texts_anim.play("event4")
	$SFX/menacing.play()



func _on_Ok_pressed():
	if $Leaderboard/Control/MarginContainer/PopupPanel/Vgrid/PlayerInfor/LineEdit.text:
		player_name = $Leaderboard/Control/MarginContainer/PopupPanel/Vgrid/PlayerInfor/LineEdit.text
	# pass the player and score. Yields make sure that the point is passed
	yield(SilentWolf.Scores.persist_score(player_name, points), "sw_score_posted")
	
	$Leaderboard/Control/MarginContainer/PopupPanel/Vgrid/PlayerInfor.hide()
	
	#update and show score
	var scores = yield(SilentWolf.Scores.get_high_scores(5), "sw_scores_received")
	for i in scores[1].size():
		
		var pos = get_node("Leaderboard/Control/MarginContainer/PopupPanel/Vgrid/Pos%d" % (i+1))
		pos.text = "Name: " + scores[1][i].player_name + " score: "+ str(scores[1][i].score)
		print(str(scores[1][i].score))
		pos.show()

	

	$Leaderboard/Control/MarginContainer/PopupPanel/Vgrid/Button.show()
	$Leaderboard/Control/MarginContainer/PopupPanel/Vgrid/Button.disabled = false



func _on_Button_pressed():
	get_tree().reload_current_scene()
	# SilentWolf.Scores.wipe_leaderboard()


