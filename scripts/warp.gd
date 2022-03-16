extends Spatial

export(NodePath) var player_path
export(NodePath) var target_path
export(float, 0, 10, 0.01) var duration = 0.1
var timer

var player

func _ready():
	timer = $timer

func _warp_start():
	player = get_node(player_path)
	player.playable = false
	player.velocity = Vector3.ZERO
	player.dir = Vector3.ZERO
	fader._fade_out(duration)
	timer.start(duration)

func _move_player():
	fader._fade_in(duration)
	var target = get_node(target_path)
	player.global_transform = target.global_transform
	player.playable = true
