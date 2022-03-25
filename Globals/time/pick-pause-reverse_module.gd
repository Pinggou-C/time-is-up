extends Spatial

var positions = []
var oldposs
var velocities = []
var newvel
var oldstate
var cancel_reverse = false
var button
var counter =0
var oldpos = Vector3.ZERO
var olddelta = 0
var amountttt = 0
var parent = "rigid"
var pickedup = false
var state = "normal"
export (String, "Pause", "reverse", "both", "none") var type = "none"
export (bool) var weighted = false
export (bool) var grabable = false
var position_array = []
var previous_position
var old_velocity = Vector3.ZERO

func _ready():
	set_physics_process(false)
	if type == "Pause":
		add_to_group("pauseable")
	if type == "reverse":
		add_to_group("reverseable")
		positions.push_front(stepif(get_parent().get_global_transform().origin, 0.01))
		set_physics_process(true)
	if type == "both":
		add_to_group("Pause-&reverse-able")
		add_to_group("reverseable")
		add_to_group("pauseable")
		positions.push_front(stepif(get_parent().get_global_transform().origin, 0.01))
		set_physics_process(true)
	if weighted:
		add_to_group("weighted")
	collision_layer()

func collision_layer():
	if type != "none":
		get_parent().set_collision_layer_bit(2, true)
		if type !="pause":
			get_parent().set_collision_layer_bit(5, true)
			add_to_group("pickable")
	if weighted:
		get_parent().set_collision_layer_bit(3, true)
	if grabable:
		get_parent().set_collision_layer_bit(1, true)


func _physics_process(delta):
	#print(get_parent())
	olddelta = delta
	
	oldpos = get_parent().get_global_transform().origin
	var parpos = stepif(oldpos, 0.01)
	if state == "normal" || pickedup:
		if oldposs != parpos || (button != null && counter < 2):
			amountttt +=1 
			if amountttt == 1200:
				amountttt = 0
			if amountttt % 12 == 0:
				counter += delta
				var _X0 = parpos
				var vel = Vector3.ZERO
				if !positions.size() == 0:
					_X0 = positions[0]
					if positions.size() > 1: 
						vel = (positions[0] - positions[1])
				var _X12 = parpos
				var _Xrel = (_X12 - _X0)
				var _X1 = stepif(_X0+(_Xrel/ 12 + vel/12/1), 0.01)
				var _X2 = stepif(_X1+((_X12 - _X1)/ 11 + vel/12/2), 0.01)
				var _X3 = stepif(_X2+((_X12 - _X2)/ 10 + vel/12/3), 0.01)
				var _X4 = stepif(_X3+((_X12 - _X3)/ 9 + vel/12/4),0.01) 
				var _X5 = stepif(_X4+((_X12 - _X4)/ 8 + vel/12/5), 0.01)
				var _X6 = stepif(_X5+((_X12 - _X5)/ 7 + vel/12/6), 0.01)
				var _X7 = stepif(_X6+((_X12 - _X6)/ 6 + vel/12/7), 0.01)
				var _X8 = stepif(_X7+((_X12 - _X7)/ 5 + vel/12/8), 0.01)
				var _X9 = stepif(_X8+((_X12 - _X8)/ 4 + vel/12/9), 0.01)
				var _X10 = stepif(_X9+((_X12 - _X9)/ 3 + vel/12/10), 0.01)
				var _X11 = stepif(_X10+((_X12 - _X10)/ 2 + vel/12/11), 0.01)
				var _X_ = [_X1, _X2, _X3, _X4, _X5, _X6, _X7, _X8, _X9, _X10, _X11, _X12]
				for _X in _X_:
					positions.push_front(_X)
				
				if cancel_reverse == true:
					cancel_reverse = false
				if parent == "rigid":
					velocities.push_front(get_parent().linear_velocity)
	elif state == "reversed":
		if !pickedup && !cancel_reverse:
			get_parent().global_transform.origin= get_parent().global_transform.origin.move_toward(positions[0], 1)
			#get_parent().global_transform.origin = positions[0]
			#if amountttt % 2 == 0:
			positions.remove(0)
			if positions.size() == velocities.size() -1:
				velocities.remove(0)
			if velocities.size() > 0:
				newvel = velocities[0]
			if positions.size() == 0:
				cancel_reverse = true
	if oldstate == "reversed" && state != "reversed":
		if state == "normal":
			if newvel != null:
				if parent == "rigid":
					get_parent().linear_velocity = newvel
		elif state == "paused":
			old_velocity = newvel
			newvel = null
	oldstate = state
	oldposs = parpos

func pause():
	get_parent().get_child(2).get_child(0).visible = true
	get_parent().get_child(2).get_child(1).visible = false
	if pickedup == false:
		if parent == "rigid":
			old_velocity = get_parent().linear_velocity
			var _body := rigid_to_kinem(get_parent())
			collision_layer()
			parent = "kinem"
		elif parent == "static":
			var _body := static_to_kinem(get_parent())
			collision_layer()
			parent = "kinem"
	state = "paused"
	
func Continue():
	get_parent().get_child(2).get_child(0).visible = false
	get_parent().get_child(2).get_child(1).visible = false
	if pickedup == false:
		if parent == "kinem":
			var _body := kinem_to_rigid(get_parent())
		elif parent == "static":
			var _body := static_to_rigid(get_parent())
		$Tween.interpolate_property(get_parent(), "linear_velocity", Vector3.ZERO, old_velocity, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		old_velocity = Vector3.ZERO
		collision_layer()
		parent = "rigid"
	state = "normal"

func reverse():
	get_parent().get_child(2).get_child(0).visible = false
	get_parent().get_child(2).get_child(1).visible = true
	if pickedup == false:
		if parent == "rigid":
			var _body := rigid_to_kinem(get_parent())
			collision_layer()
			parent = "kinem"
		elif parent == "static":
			var _body := static_to_kinem(get_parent())
			collision_layer()
			parent = "kinem"
	state = "reversed"


func picked_up():
	var body = get_parent()
	pickedup = true
	if parent == "rigid":
		body = rigid_to_kinem(get_parent())
		parent = "kinem"
	elif parent == "static":
		body = static_to_kinem(get_parent())
		parent = "kinem"
	return body
	

func drop(vel):
	var body = get_parent()
	pickedup = false
	if state == "paused":
		if parent == "rigid":
			rigid_to_kinem(get_parent())
			get_parent().get_child(2).get_child(0).visible = true
			get_parent().get_child(2).get_child(1).visible = false
			parent = "kinem"
		if parent == "static":
			get_parent().get_child(2).get_child(0).visible = false
			get_parent().get_child(2).get_child(1).visible = true
			static_to_kinem(get_parent())
			parent = "kinem"
	elif state == "reversed":
		if parent == "rigid":
			get_parent().get_child(2).get_child(0).visible = false
			get_parent().get_child(2).get_child(1).visible = true
			rigid_to_kinem(get_parent())
			parent = "kinem"
		if parent == "static":
			get_parent().get_child(2).get_child(0).visible = false
			get_parent().get_child(2).get_child(1).visible = true
			static_to_kinem(get_parent())
			parent = "kinem"
	elif state == "normal":
		get_parent().get_child(2).get_child(0).visible = false
		get_parent().get_child(2).get_child(1).visible = false
		body = kinem_to_rigid(get_parent())
		get_parent().linear_velocity = vel
		parent = "rigid"
	collision_layer()
	return body
# Replace `Physicsbody`
func trans_body(to: PhysicsBody, from: PhysicsBody) -> void:
	to.transform = from.transform
	from.replace_by(to)
	from.queue_free()

# Convert a `RigidBody` scene node to `KinematicBody`
func rigid_to_kinem(rigid: RigidBody) -> KinematicBody:
	var kinem := KinematicBody.new()
	trans_body(kinem, rigid)
	return kinem
# Convert a `RigidBody` scene node to `StaticBody`
func rigid_to_static(rigid: RigidBody) -> StaticBody:
	var stat := StaticBody.new()
	trans_body(stat, rigid)
	return stat

# Convert a `KinematicBody` scene node to `RigidBody`
func kinem_to_rigid(kinem: KinematicBody) -> RigidBody:
	var rigid := RigidBody.new()
	trans_body(rigid, kinem)
	return rigid
# Convert a `KinematicBody` scene node to `StaticBody`
func kinem_to_static(kinem: KinematicBody) -> StaticBody:
	var stat := StaticBody.new()
	trans_body(stat, kinem)
	return stat

# Convert a `StaticBody` scene node to `KinematicBody`
func static_to_kinem(Static: StaticBody) -> KinematicBody:
	var kinem := KinematicBody.new()
	trans_body(kinem, Static)
	return kinem
# Convert a `StaticBody` scene node to `RigidBody`
func static_to_rigid(Static: StaticBody) -> RigidBody:
	var rigid := RigidBody.new()
	trans_body(rigid, Static)
	return rigid


func on_button(butt, on):
	if on:
		if state != 'reverse':
			button = butt
			counter = 0
	else:
		button = null
		counter = 0


func vel():
	var ve = (get_parent().get_global_transform().origin - oldpos)
	return ve


func stepif(num, amount = 0.01):
	return Vector3(stepify(num.x, amount), stepify(num.y, amount), stepify(num.z, amount))
