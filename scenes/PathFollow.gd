extends PathFollow

export(int) var sped = 0
var state = "normal"
export (String, "Pause", "reverse", "both", "none") var type = "none"
var dir = 1
var olddir = 1

func pause():
	print('paus')
	if state == "reversed":
		print('r')
		olddir = -dir
	elif state == "normal":
		print('rv')
		olddir = dir
	state = "paused"
	dir = 0

func Continue():
	print('con')
	if state == "reversed":
		print('rvv')
		dir *= -1
	elif state == "paused":
		print('rvvv')
		dir = olddir
	state = "normal"

func reverse():
	print('rev')
	if state == "normal":
		print('rvvvv')
		dir *= -1
	elif state == "paused":
		print('rvvvvv')
		dir = -olddir
	state = "reversed"


func _ready():
	get_child(0).add_to_group("moving_platform")
	if type == "Pause":
		get_child(0).add_to_group("pauseable")
	if type == "reverse":
		get_child(0).add_to_group("reverseable")
	if type == "both":
		get_child(0).add_to_group("Pause-&reverse-able")
		get_child(0).add_to_group("reverseable")
		get_child(0).add_to_group("pauseable")
	set_physics_process(false)

func _physics_process(delta):
	#print(dir, olddir)
	if  abs(10.19 - offset) <sped/2 :
		offset += (abs(10.19 - offset)+0.5)*delta*dir
	elif  offset < sped/2:
		offset += (offset+0.5)*delta*dir
	else:
		offset += sped*delta*dir
	if stepify(unit_offset, 0.01) == 1:
		dir = -1
	elif stepify(unit_offset, 0.01) == 0:
		dir = 1

func _on_Area_body_entered(body):
	print('hi')
	set_physics_process(true)

