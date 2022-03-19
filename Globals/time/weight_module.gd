extends Spatial


func _ready():
	get_parent().add_to_group("weighted")
	get_parent().set_collision_layer_bit(3, true)
