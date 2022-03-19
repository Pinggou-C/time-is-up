extends Spatial

var picked_up = false
var state = "normal"
export (String, "Pause", "reverse", "both") var type

var position_array = []
var previous_position

func _ready():
	set_physics_process(false)
	if type == "reverse" || type == "both":
		set_physics_process(true)

func _physics_process(delta):
	pass

func pause():
	if picked_up == false:
		get_parent().sleeping = true
	state = "paused"

func Continue():
	if picked_up == false:
		get_parent().sleeping = false
	state = "normal"

func Reverse():
	if picked_up == false:
		pass


func picked_up():
	picked_up = true

func drop():
	picked_up = false
	if state == "paused":
		get_parent().sleeping = true
	elif state == "reversed":
		pass
		#get_parent().sleeping = true
