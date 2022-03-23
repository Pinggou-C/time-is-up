extends StaticBody

export (NodePath) var node_path  = null
onready var connected = get_node(node_path)
var on_top = []
var powered = false
var temp_body
var temp_body_enter

func _ready():
	if connected != null:
		connected.Connect(self)

func power():
	if connected != null:
		connected.power(self)
	powered = true

func unpower():
	if connected != null:
		connected.unpower(self)
	powered = false


func _on_Area_body_entered(body):
	if body.get_child(0).is_in_group("weighted"):
		print("hi")
		temp_body_enter = body.get_child(0)
		$Timer2.start(0.1)
		if !$Timer.is_stopped():
			$Timer.stop()
			print("sike")
			temp_body = null
		
		


func _on_Area_body_exited(body):
	if body.get_child(0).is_in_group("weighted"):
		print("bye")
		temp_body = body.get_child(0)
		$Timer.start(0.1)
		temp_body_enter = null
		if !$Timer2.is_stopped():
			$Timer2.stop()
			print("sike, you dont enter")
			temp_body_enter = null
	
	


func _on_Tween_tween_completed(_object, _key):
	$AnimationPlayer.playback_speed = 1

func _on_Timer_timeout():
	print("now actually")
	var body = temp_body
	temp_body = null
	on_top.erase(body)
	body.on_button(self, false)
	if !on_top.size() > 0:
		print('ji')
		if $AnimationPlayer.is_playing():
			#var time = 0.4 - ($AnimationPlayer.current_animation_position)
			$AnimationPlayer.play("up")
			#$AnimationPlayer.seek(time, true)
		else:
			$AnimationPlayer.play("up")
			#$AnimationPlayer.seek(0, true)


func _on_Timer2_timeout():
	print("actually hi")
	var body = temp_body_enter
	if on_top.has(body) == false:
		temp_body_enter = null
		body.on_button(self, true)
		if !on_top.size() > 0:
			print("actually hi")
			if $AnimationPlayer.is_playing():
				#var time = 0.4 - ($AnimationPlayer.current_animation_position)
				$AnimationPlayer.play("down")
				#$AnimationPlayer.seek(time, true)
			else:
				$AnimationPlayer.play("down")
				#$AnimationPlayer.seek(0, true)
		on_top.append(body)
	
