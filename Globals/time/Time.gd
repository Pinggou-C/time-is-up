extends Node

const times = {"normal" : 1, "reversed" : 2, "paused" : 0}
var time = "normal" setget update_time
var pause_available = false
var reverse_available = false

func _ready():
	self.set_pause_mode(2)

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		
		if time == "paused":
			print('hsi')
			time = "normal"
			get_tree().paused = false
		else:
			time = "paused"
			print('hi')
			get_tree().paused = true
	if Input.is_action_just_pressed("reverse"):
		if time == "reversed":
			time = "normal"
		else:
			time = "reversed"

func update_time(new_time):
	if times.has(new_time):
		if time == "paused":
			if new_time == "reversed":
				get_tree().call_group("pauseable","Continue")
				get_tree().call_group("reverseable","Reverse")
				get_tree().call_group("Pause-&reverse-able","Reverse")
			elif new_time == "normal":
				get_tree().call_group("pauseable","Continue")
				get_tree().call_group("Pause-&reverse-able","Continue")
		elif time == "normal":
			if new_time == "reversed":
				get_tree().call_group("reverseable","Reverse")
				get_tree().call_group("Pause-&reverse-able","Reverse")
			elif new_time == "paused":
				get_tree().call_group("pauseable","Pause")
				get_tree().call_group("Pause-&reverse-able","Pause")
		elif time == "reversed":
			if new_time == "paused":
				get_tree().call_group("pauseable","Pause")
				get_tree().call_group("Pause-&reverse-able","Pause")
				get_tree().call_group("reverseable","Continue")
			elif new_time == "normal":
				get_tree().call_group("reverseable","Continue")
				get_tree().call_group("Pause-&reverse-able","Continue")
		
		
		
		
		
		
		get_tree().call_group("Pause-&reverse-able","reverse")
	time = new_time
