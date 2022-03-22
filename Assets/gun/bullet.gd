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
	if goal == 'pause':
		$MeshInstance2.get_surface_material(0).albedo_color = Color(0, 0, 1)
		$MeshInstance2.get_surface_material(0).emission = Color(0, 0, 1)
		$MeshInstance.get_surface_material(0).set_shader_param("_ColorRim", Color(0, 0, 1))
	if goal == 'reverse':
		$MeshInstance2.get_surface_material(0).albedo_color = Color(1, 0, 0)
		$MeshInstance2.get_surface_material(0).emission = Color(1, 0, 0)
		$MeshInstance.get_surface_material(0).set_shader_param("_ColorRim", Color(1, 0, 0))

func _physics_process(delta):
	#global_transform.origin +=  delta
	transform.origin += direction * velocity * delta

#detect_collisions
func _on_Bullet_body_entered(body):
	var bod = body.get_child(0)
	var bod2 = body.get_child(0)
	if body.is_in_group("moving_platform"):
		bod2 = body.get_parent()
		bod = body
	if type == "pause" && bod.is_in_group("pauseable"):
		fired_by.new_item(bod2, type, self)
	elif type == "reverse" && bod.is_in_group("reverseable"):
		fired_by.new_item(bod2, type, self)
	fired_by.projectile_destroyed(type, self)

#destroy bullet after set time
func _on_deathtimer_timeout():
	fired_by.projectile_destroyed(type, self)
