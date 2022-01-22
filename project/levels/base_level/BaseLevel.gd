extends Spatial

onready var player := $PlayerBoat
onready var wasted_overlay := $UI/WastedOverlay

func _ready():
	for shark in get_tree().get_nodes_in_group("sharks"):
		shark.connect("chasing", self, "on_shark_chasing")
		shark.connect("chasing", self, "on_shark_lose_target")

func move_player_to_initial_position():
	wasted_overlay.hide_overlay()


func on_shark_chasing():
	pass
	
	
func on_shark_lose_target():
	pass
