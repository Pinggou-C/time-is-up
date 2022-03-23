extends StaticBody

var items = []
var powered_by = []
var powered


func Connect(item):
	items.append(item)

func power(item):
	powered_by.append(item)
	if powered_by.hash() == items.hash():
		power_on()

func unpower(item):
	powered_by.erase(item)
	power_off()

func power_on():
	if $AnimationPlayer.is_playing():
		if $AnimationPlayer.current_animation == "close":
			#var time = 0.8 - ($AnimationPlayer.current_animation_position * 2)
			$AnimationPlayer.play("open")
			#$AnimationPlayer.seek(time, true)
	else:
		$AnimationPlayer.play("open")
		#$AnimationPlayer.seek(0, true)
	powered = true
	

func power_off():
	if $AnimationPlayer.is_playing():
		if $AnimationPlayer.current_animation == "open":
			#var time = 0.4 - ($AnimationPlayer.current_animation_position / 2)
			$AnimationPlayer.play("close")
			#$AnimationPlayer.seek(time, true)
	else:
		$AnimationPlayer.play("close")
		#$AnimationPlayer.seek(0, true)
	powered = false


func _on_Tween_tween_all_completed():
	$AnimationPlayer.playback_speed = 1
