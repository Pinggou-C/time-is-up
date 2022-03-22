extends StaticBody

var oldstate = 'normal'
var powered = false
var state = "normal"
export(bool) var automove = false
export (String, "Pause", "reverse", "both", "none") var type = "both"
export (int, 0, 100) var speed = 5
export (bool) var on_step = false
var velocity = Vector3.ZERO
var originalpos = Vector3.ZERO
var goalpos = Vector3.ZERO

func Connect(by):
	pass

func _ready():
	var kids = get_parent().get_children()
	var kids2 = []
	for kid in kids:
		if kid is Position3D:
			kids2.append(kid)
	var ori = kids2[0].get_global_transform().origin
	originalpos =Vector3(stepify(ori.x, 0.01), stepify(ori.y, 0.01), stepify(ori.z, 0.01))
	global_transform.origin = kids2[0].get_global_transform().origin
	var kidpos = kids2[1].get_global_transform().origin
	goalpos = Vector3(stepify(kidpos.x, 0.01), stepify(kidpos.y, 0.01), stepify(kidpos.z, 0.01))
	set_physics_process(false)
	if type == "Pause":
		get_child(0).add_to_group("pauseable")
	if type == "reverse":
		get_child(0).add_to_group("reverseable")
		set_physics_process(true)
	if type == "both":
		get_child(0).add_to_group("Pause-&reverse-able")
		get_child(0).add_to_group("reverseable")
		get_child(0).add_to_group("pauseable")
		set_physics_process(true)
	Collision_layer()
	print(originalpos, goalpos)

func _physics_process(delta):
	var pos = Vector3(stepify(get_global_transform().origin.x, 0.01), stepify(get_global_transform().origin.y, 0.01), stepify(get_global_transform().origin.z, 0.01))
	velocity = Vector3.ZERO
	if !automove:
		if powered == true:
			print("hi")
			if state == 'paused':
				velocity = Vector3.ZERO
			elif state == 'normal':
				if pos != goalpos:
					print("hi3")
					if abs(goalpos.y - pos.y) >1:
						print("hi4")
						velocity.y = speed
					else:
						velocity.y = (goalpos.y - pos.y)* 2
			elif state == 'reversed':
				if pos != originalpos:
					if abs(originalpos.y - pos.y) >1:
						velocity.y = -speed
					else:
						velocity.y =  (originalpos.y - pos.y )* 2
		if powered == false:
			if state == 'paused':
				velocity = Vector3.ZERO
			elif state == 'normal':
				if pos != originalpos:
					if abs(originalpos.y - pos.y) >1:
						velocity.y = -speed
					else:
						velocity.y =  (originalpos.y - pos.y)* 2
			elif state == 'reversed':
				velocity = Vector3.ZERO
	#print(velocity)
	translate(velocity*delta)
	#velocity = move_and_collide(velocity*delta, false, 4)
	oldstate = state


func Collision_layer():
	if type != "none":
		set_collision_layer_bit(2, true)
	if on_step:
		$Area.set_collision_mask_bit(4, true)

func pause():
	state = 'paused'
	print("pause")

func reverse():
	state = "reversed"

func Continue():
	state = "normal"

func power(by):
	powered = true

func unpower(by):
	powered = false


func _on_Area_body_entered(body):
	pass # Replace with function body.
