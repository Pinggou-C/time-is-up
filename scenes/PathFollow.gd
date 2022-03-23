tool
extends PathFollow

export(int) var sped = 0
var state = "normal"
export (String, "Pause", "reverse", "both", "none") var type = "none"
export (Array, Vector3) var positions setget pos
var dir = 1
var olddir = 1
var path = []

func pause():
	if state == "reversed":
		olddir = -dir
	elif state == "normal":
		olddir = dir
	state = "paused"
	dir = 0

func Continue():
	if state == "reversed":
		dir *= -1
	elif state == "paused":
		dir = olddir
	state = "normal"

func reverse():
	if state == "normal":
		dir *= -1
	elif state == "paused":
		dir = -olddir
	state = "reversed"


func _ready():
	print(get_parent())
	for i  in get_parent().get_curve().get_point_count():
		path.append(get_parent().get_curve().get_point_position(i))
	print(path)
	#var vectors = PoolVector2Array(Array([path]))
	#print(vectors)
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

func _on_Area_body_entered(_body):
	print('hi')
	set_physics_process(true)

func vel():
	pass

func pos(new):
	print(self,get_parent())
	print(new)
	for i in new:
		var node = Position3D.new()
		add_child(node)
		node.translation = i 
		print(node.get_global_transform().origin)
	positions = new
