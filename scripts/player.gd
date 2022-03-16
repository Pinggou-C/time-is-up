extends KinematicBody

export var gravity = -30.0
export var walk_speed = 5.0
export var run_speed = 16.0
export var jump_speed = 10.0
export var mouse_sensitivity = 0.002
export var acceleration = 4.0
export var friction = 9.0
export var fall_limit = -1000.0

var pivot

var playable = true
var dir = Vector3.ZERO
var velocity = Vector3.ZERO

#held items
var held_item
var held_items_classes = []
var relative_position = Vector3.ZERO
var held_item_velocity = Vector3.ZERO
var held_item_speed = 10

func _ready():
	pivot = $pivot
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	dir = Vector3.ZERO
	var speed = walk_speed
	var basis = global_transform.basis
	if playable:
		if Input.is_action_pressed("move_forward"):
			dir -= basis.z
		if Input.is_action_pressed("move_back"):
			dir += basis.z
		if Input.is_action_pressed("move_left"):
			dir -= basis.x
		if Input.is_action_pressed("move_right"):
			dir += basis.x
		dir = dir.normalized()

		
		if is_on_floor():
			#this prevents you from sliding without messing up the is_on_ground() check
			velocity.y += gravity * delta / 100.0
			if Input.is_action_just_pressed("jump"):
				velocity.y = jump_speed
		else:
			velocity.y += gravity * delta

		var hvel = velocity
		hvel.y = 0.0

		var target = dir * speed
		var accel
		if dir.dot(hvel) > 0.0:
			accel = acceleration
		else:
			accel = friction
		hvel = hvel.linear_interpolate(target, accel * delta)
		velocity.x = hvel.x
		velocity.z = hvel.z
		velocity = move_and_slide(velocity, Vector3.UP, true)

		#prevents infinite falling
		if translation.y < fall_limit and playable:
			playable = false
			fader._reload_scene()

		#handles grabbing of items
		if Input.is_action_just_pressed("grab"):
			if held_item == null:
				print("test")
				if $pivot/RayCast.is_colliding():
					var coll = $pivot/RayCast.get_collider()
					print(coll)
					held_item = coll
					for group in held_item.get_groups():
						held_items_classes.append(group)
					var body := rigid_to_kinem(held_item)
					held_item = body
					relative_position = get_rel_pos(held_item)
			elif held_item != null:
				var body := kinem_to_rigid(held_item)
				if held_item_velocity != null:
					body.linear_velocity = held_item_velocity * 0.75
				else: 
					body.linear_velocity = Vector3(0.01, 0.01, 0.01)
				body.set_collision_layer_bit(1, true)
				#body.drop(held_item_velocity * 0.75)
				print(held_item_velocity)
				held_item = null
				for group in held_items_classes:
					body.add_to_group(group)
		
		if held_item != null:
			var current_position = held_item.get_global_transform().origin
			var next_position = ($pivot.get_global_transform() * relative_position).origin
			var difference = 1/sqrt(pow(current_position.x - next_position.x, 2) + pow(current_position.y - next_position.y, 2) + pow(current_position.z - next_position.z, 2))
			print(difference)
			var held_item_velocity = (next_position - current_position) / delta / 3 / sqrt(difference)
			held_item_velocity = held_item.move_and_slide(held_item_velocity, Vector3.UP, false, 4, PI/4, false)


#looking around
func _unhandled_input(event):
	if event is InputEventMouseMotion and playable:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		pivot.rotation.x = clamp(pivot.rotation.x, -1.2, 1.2)

# Get relative position of item to `Player` head
func get_rel_pos(body):
	$Tween.interpolate_property(body, "global_position",
	 body.get_global_transform(), $pivot/goal.get_global_transform(),
	 1/2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(body, "rotation_degrees",
	 body.rotation_degrees, $pivot.rotation_degrees, 1/2,
	 Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	var distance = $pivot.get_global_transform().origin - body.get_global_transform().origin
	var dis = sqrt(pow(distance.x, 2) + pow(distance.y, 2) + pow(distance.z, 2))
	return $pivot.get_global_transform().inverse() * $pivot/goal.get_global_transform()

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
