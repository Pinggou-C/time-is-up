extends Spatial

var projectile_pause = null
var projectile_reverse = null
var can_fire_pause = true
var can_fire_reverse = true
var object_pause = null
var object_reverse = null

export (PackedScene) var Bullet

#fires the gun
func _physics_process(_delta):
	if Input.is_action_just_pressed("pause") :
		can_fire_pause = false
		shoot("pause")
	if Input.is_action_just_pressed("reverse") && can_fire_reverse == true:
		can_fire_reverse = false
		shoot("reverse")

#sets new actively paused or reversed obejcts
func new_item(item, type):
	if type == "pause":
		object_pause = item
	if type == "reverse":
		object_reverse = item

#removes actively paused or reversed items
func remove_item(type):
	if type == "pause":
		if object_pause != null:
			object_pause.continue()
			object_pause = null
	elif type == "reverse":
		if object_reverse != null:
			object_reverse.continue()
			object_reverse = null
	elif type == "all":
		if object_pause != null:
			object_pause.continue()
			object_pause = null
		if object_reverse != null:
			object_reverse.continue()
			projectile_reverse = null

#removes projectiles upon impact
func projectile_destroyed(type):
	if type == "pause":
		projectile_pause.queue_free()
		projectile_pause = null
		can_fire_pause = true
	elif type == "reverse":
		projectile_reverse.queue_free()
		projectile_reverse = null
		can_fire_reverse = true

func shoot(type):
	var b = Bullet.instance()
	get_parent().get_parent().get_parent().add_child(b)
	b.start(self, type, global_transform.basis.xform(Vector3.FORWARD))
	b.transform = $Muzzle.global_transform
