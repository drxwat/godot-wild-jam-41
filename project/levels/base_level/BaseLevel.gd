extends Spatial

onready var player := $PlayerBoat
onready var wasted_overlay := $UI/WastedOverlay

var initial_position = Vector3(118.777, 0.413, 212.549)

func _ready():
	for shark in get_tree().get_nodes_in_group("sharks"):
		shark.connect("chasing", self, "on_shark_chasing")
		shark.connect("chasing", self, "on_shark_lose_target")


func on_wasted(reason: String, _money: int, _penalty: int):
	wasted_overlay.show_overlay(reason, _money, _penalty)
	yield(wasted_overlay, "penalty_finished")
	player.respawn(initial_position, _penalty)
	yield(get_tree().create_timer(1.0), "timeout")
	wasted_overlay.hide_overlay()


func on_shark_chasing():
	pass
	
	
func on_shark_lose_target():
	pass
