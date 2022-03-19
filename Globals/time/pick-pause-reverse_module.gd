extends Spatial

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
	pass

func pause():
	if picked_up == false:
		old_velocity = get_parent().linear_velocity
		var body := rigid_to_kinem(get_parent())
		collision_layer()
		parent = "kinem"
	state = "paused"

func Continue():
	if picked_up == false:
		var body := kinem_to_rigid(get_parent())
		$Tween.interpolate_property(get_parent(), "linear_velocity", Vector3.ZERO, old_velocity, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
		old_velocity = Vector3.ZERO
		collision_layer()
		parent = "rigid"
	state = "normal"

func Reverse():
	if picked_up == false:
		pass


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
		pass
	elif state == "reversed":
		pass
	elif state == "normal":
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
