extends Spatial

var projectile_pause = []
var projectile_reverse = []
var can_fire_pause = true
var can_fire_reverse = true
var object_pause = null
var object_reverse = null

export (PackedScene) var Bullet

#fires the gun
func _physics_process(_delta):
	if Input.is_action_just_pressed("pause") && can_fire_pause == true :
		can_fire_pause = false
		can_fire_reverse = false
		$general.start(0.333)
		shoot("pause")
	if Input.is_action_just_pressed("reverse") && can_fire_reverse == true:
		can_fire_reverse = false
		can_fire_pause = false
		shoot("reverse")
		$general.start(0.333)
	if Input.is_action_just_pressed("clear"):
		remove_item("all")

#sets new actively paused or reversed obejcts
func new_item(item, type, bullet):
	
	if type == "pause":
		if object_pause != null:
			remove_item(type)
		object_pause = item
		item.pause()
	if type == "reverse":
		if object_reverse != null:
			remove_item(type)
		object_reverse = item
		item.reverse()

#removes actively paused or reversed items
func remove_item(type):
	if type == "pause":
		if object_pause != null:
			object_pause.Continue()
			object_pause = null
	elif type == "reverse":
		if object_reverse != null:
			object_reverse.Continue()
			object_reverse = null
	elif type == "all":
		if object_pause != null:
			object_pause.Continue()
			object_pause = null
		if object_reverse != null:
			object_reverse.Continue()
			object_reverse = null

#removes projectiles upon impact
func projectile_destroyed(type, bullet = null):
	if type == "pause":
		bullet.queue_free()
		projectile_pause.erase(bullet)
	elif type == "reverse":
		bullet.queue_free()
		projectile_reverse.erase(bullet)
	elif type == "all":
		for bullet_reverse in projectile_reverse:
			projectile_reverse.erase(bullet_reverse)
			bullet_reverse.queue_free()
		for bullet_pause in projectile_pause:
			projectile_pause.erase(bullet_pause)
			bullet_pause.queue_free()

func shoot(type):
	var b = Bullet.instance()
	$PART.emitting = true
	get_parent().get_parent().get_parent().add_child(b)
	if type == "pause":
		projectile_pause.append(b)
	elif type == "reverse":
		projectile_reverse.append(b)
	b.start(self, type, global_transform.basis.xform(Vector3.FORWARD))
	b.transform = $Muzzle.global_transform
	$PART.emitting = false

func _on_general_timeout():
	can_fire_pause = true
	can_fire_reverse = true
