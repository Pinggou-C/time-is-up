extends KinematicBody

export var gravity = -30.0
export var walk_speed = 5.0
export var run_speed = 16.0
export var jump_speed = 10.0
export var mouse_sensitivity = 0.002
export var acceleration = 10.0
export var friction = 9.0
export var fall_limit = -1000.0
var oldvel = Vector3.ZERO
var pivot

var just_jumped = false
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
	var extravel = Vector3.ZERO
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
		var snap 
		
		if is_on_floor():
			var colsped = Vector3.ZERO
			snap = Vector3.DOWN *20
			print(snap)
			#var collid = false
			#this prevents you from sliding without messing up the is_on_ground() check
			#var nr = 0
			#var playform = $playform.get_children()
			#while nr < playform.size()-1 && collid == false:
				#nr+=1
				#if playform[nr].is_colliding():
				#	collid = true
				#	var coll = playform[nr].get_collider()
				#	if coll.get_child(0).is_in_group("pickable"):
				#		if coll.get_child(0).parent == "static":
				#			pass
							#extravel = coll.get_child(0).vel()/delta
							#if extravel != Vector3.ZERO:
								#var xtravel = (-get_global_transform().origin + coll.get_global_transform().origin) /delta *1.5
								#print(xtravel, ":g")
								#extravel.x += xtravel.x 
								#extravel.z += xtravel.z 
								#extravel.y += xtravel.y
								#global_transform.origin += xtravel
				#	else:
				#		velocity.y = coll.velocity.y
			#if collid == false:
			velocity.y += gravity * delta / 100.0
			if Input.is_action_just_pressed("jump"):
				velocity.y = colsped.y + jump_speed
				snap = Vector3.ZERO
				just_jumped = true
		else:
			var ex = 1
			snap = Vector3.ZERO
			print(snap)
			#var collid = false
			#var nr = 0
			#var playform = $playform.get_children()
			#while nr < playform.size()-1 && collid == false:
			#	nr+=1
				#if playform[nr].is_colliding():
				#	collid = true
				#	var coll = playform[nr].get_collider()
				#	if coll.get_child(0).is_in_group("pickable"):
				#		if coll.get_child(0).parent == "static":
				#			pass
							#ex = 2
							#extravel = coll.get_child(0).vel()/delta
							#if extravel != Vector3.ZERO:
							#	var xtravel = (-get_global_transform().origin + coll.get_global_transform().origin) /delta *1.5
							#	print(xtravel, ":g")
							#	extravel.x += xtravel.x
							#	extravel.z += xtravel.z
							#	extravel.y += xtravel.y 
								#global_transform.origin += xtravel
				#	else:
				#		velocity.y = coll.velocity.y
			#i#f collid == false:
			velocity.y += gravity * delta * ex
			if velocity.y > 0 && just_jumped == true:
				just_jumped = true
			if Input.is_action_just_released("jump") && just_jumped == true:
				velocity.y /= 2

		var hvel = velocity
		hvel.y = 0.0

		var target = dir * speed #+ extravel * 2
		var accel
		if dir.dot(hvel) > 0.0:
			accel = acceleration
		else:
			accel = friction
		hvel = hvel.linear_interpolate(target, accel * delta)
		velocity.x =  hvel.x #+ extravel.x
		velocity.z =  hvel.z #+ extravel.z
		#print(extravel, velocity)
		#extravel = slide(extravel, Vector3.UP, false, 4, PI/4, false)
		
		velocity = move_and_slide_with_snap(velocity,snap, Vector3.UP, false, 4, PI/4, false)
		
		#velocity.x -=  extravel.x
		#velocity.z -=  extravel.z
		"""if abs(velocity.x - oldvel.x) >20:
			print(1)
			velocity.x = oldvel.x #+velocity.x / 500
		if abs(velocity.y - oldvel.y) >20:
			print(2)
			velocity.y = oldvel.y #+velocity.y / 500
		if abs(velocity.z - oldvel.z) >20:
			print(3)
			velocity.z = oldvel.z #+velocity.z / 500
		oldvel = velocity"""

		#prevents infinite falling
		if translation.y < fall_limit and playable:
			playable = false
			fader._reload_scene()

		#handles grabbing of items
		if Input.is_action_just_pressed("grab"):
			if held_item == null:
				#print("test")
				if $pivot/RayCast.is_colliding():
					var coll = $pivot/RayCast.get_collider()
					held_item = coll
					for group in held_item.get_groups():
						held_items_classes.append(group)
					var body = held_item.get_child(0).picked_up()
					held_item = body
					relative_position = get_rel_pos(held_item)
			elif held_item != null:
				drop_item()
		
		if held_item != null:
			var current_position = held_item.get_global_transform().origin
			var next_position = ($pivot.get_global_transform() * relative_position).origin
			var difference = sqrt(pow(current_position.x - next_position.x, 2) + pow(current_position.y - next_position.y, 2) + pow(current_position.z - next_position.z, 2))
			var difference_player = sqrt(pow(current_position.x - $pivot.get_global_transform().origin.x, 2) + pow(current_position.y - $pivot.get_global_transform().origin.y, 2) + pow(current_position.z - $pivot.get_global_transform().origin.z, 2))
			#var current_rotation = held_item.rotation_degrees.y
			#var _next_rotation = rotation_degrees.y
			#print(angle_difference(held_item.rotation_degrees.y, rotation_degrees.y))
			held_item.rotation_degrees.y = lerp(held_item.rotation_degrees.y, held_item.rotation_degrees.y + angle_difference(held_item.rotation_degrees.y, rotation_degrees.y), 0.2)
			if difference > 1.5 && difference_player > 3.5:
				drop_item()
			else:
				held_item_velocity = (next_position - current_position) / delta / 3 / sqrt((1/difference))
				held_item_velocity = held_item.move_and_slide(held_item_velocity, Vector3.UP, false, 4, PI/4, false)


#looking around
func _unhandled_input(event):
	if event is InputEventMouseMotion and playable:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		pivot.rotation.x = clamp(pivot.rotation.x, -1.75, 1.9)

# Get relative position of item to `Player` head
func get_rel_pos(body):
	#$Tween.interpolate_property(body, "rotation_degrees.x",
	# body.rotation_degrees.y, rotation_degrees.y + 90, 1/3,
	# Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	var distance = $pivot.get_global_transform().origin - body.get_global_transform().origin
	var _dis = sqrt(pow(distance.x, 2) + pow(distance.y, 2) + pow(distance.z, 2))
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

# Drop held item
func drop_item():
	var vel = Vector3(0.01, 0.01, 0.01)
	if held_item_velocity != null:
		vel = held_item_velocity * 0.75
	var body = held_item.get_child(0).drop(vel)
	print(held_item_velocity)
	held_item = null
	for group in held_items_classes:
		body.add_to_group(group)

func angle_difference(angle1, angle2):
	var diff = angle2 - angle1
	return diff if abs(diff) < 180 else diff + (360 * -sign(diff))
