extends Area

var type = null
var velocity = 35
var fired_by
var direction = Vector3.ZERO

func start(gun, goal, dir):
	type = goal
	fired_by = gun
	var dir_devider = abs(dir.x) + abs(dir.y) + abs(dir.z)
	direction = Vector3(dir.x / dir_devider,dir.y / dir_devider, dir.z / dir_devider)
	$deathtimer.start(10)

func _physics_process(delta):
	#global_transform.origin +=  delta
	transform.origin += direction * velocity * delta

#detect_collisions
func _on_Bullet_body_entered(body):
	if type == "pause" && body.get_child(0).is_in_group("pauseable"):
		fired_by.new_item(body.get_child(0), type, self)
	elif type == "reverse" && body.get_child(0).is_in_group("reverseable"):
		fired_by.new_item(body.get_child(0), type, self)
	fired_by.projectile_destroyed(type, self)

#destroy bullet after set time
func _on_deathtimer_timeout():
	fired_by.projectile_destroyed(type, self)
