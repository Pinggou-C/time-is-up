extends Spatial

var positions = []
var oldposs
var velocities = []
var newvel
var oldstate
var cancel_reverse = false
var button
var counter =0

var parent = "rigid"
var picked_up = false
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
		set_physics_process(true)
	if type == "both":
		add_to_group("Pause-&reverse-able")
		add_to_group("reverseable")
		add_to_group("pauseable")
		set_physics_process(true)
	if weighted:
		add_to_group("weighted")
	collision_layer()

func collision_layer():
	if type != "none":
		get_parent().set_collision_layer_bit(2, true)
	if weighted:
		get_parent().set_collision_layer_bit(3, true)
	if grabable:
		get_parent().set_collision_layer_bit(1, true)


func _physics_process(delta):
	var parpos = Vector3(stepify(get_parent().get_global_transform().origin.x, 0.01), stepify(get_parent().get_global_transform().origin.y, 0.01), stepify(get_parent().get_global_transform().origin.z, 0.01))
	if state == "normal" || picked_up:
		if oldposs != parpos || (button != null && counter < 2):
			counter += delta
			positions.push_front(parpos)
			if cancel_reverse == true:
				cancel_reverse = false
			if parent == "rigid":
				velocities.push_front(get_parent().linear_velocity)
	elif state == "reversed":
		if !picked_up && !cancel_reverse:
			get_parent().global_transform.origin = positions[0]
			positions.remove(0)
			if velocities.size() > 0:
				newvel = velocities[0]
			if positions.size() == velocities.size() -1:
				velocities.remove(0)
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
	if picked_up == false:
		if parent == "rigid":
			old_velocity = get_parent().linear_velocity
			var body := rigid_to_kinem(get_parent())
			collision_layer()
			parent = "kinem"
	state = "paused"
	
func Continue():
	get_parent().get_child(2).get_child(0).visible = false
	get_parent().get_child(2).get_child(1).visible = false
	if picked_up == false:
		if parent == "kinem":
			var body := kinem_to_rigid(get_parent())
		$Tween.interpolate_property(get_parent(), "linear_velocity", Vector3.ZERO, old_velocity, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		old_velocity = Vector3.ZERO
		collision_layer()
		parent = "rigid"
	state = "normal"

func reverse():
	get_parent().get_child(2).get_child(0).visible = false
	get_parent().get_child(2).get_child(1).visible = true
	if picked_up == false:
		if parent == "rigid":
			var body := rigid_to_kinem(get_parent())
			collision_layer()
			parent = "kinem"
	state = "reversed"


func picked_up():
	var body = get_parent()
	picked_up = true
	if parent == "rigid":
		body = rigid_to_kinem(get_parent())
		parent = "kinem"
	return body

func drop(vel):
	var body = get_parent()
	picked_up = false
	if state == "paused":
		if parent == "rigid":
			rigid_to_kinem(get_parent())
			get_parent().get_child(2).get_child(0).visible = true
			get_parent().get_child(2).get_child(1).visible = false
			parent = "kinem"
	elif state == "reversed":
		if parent == "rigid":
			get_parent().get_child(2).get_child(0).visible = false
			get_parent().get_child(2).get_child(1).visible = true
			rigid_to_kinem(get_parent())
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

# Convert a `KinematicBody` scene node to `RigidBody`
func kinem_to_rigid(kinem: KinematicBody) -> RigidBody:
	var rigid := RigidBody.new()
	trans_body(rigid, kinem)
	return rigid

func on_button(butt, on):
	if on:
		if state != 'reverse':
			button = butt
			counter = 0
	else:
		button = null
		counter = 0
