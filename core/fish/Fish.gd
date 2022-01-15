extends StaticBody
class_name Fish

var time_to_pick_up := 30.0
var meta: FishMeta

onready var sprite := $Sprite3D

func _ready():
	meta = FishMeta.new()

func _process(delta: float):
	time_to_pick_up -= delta
	if time_to_pick_up <= 0:
		remove_self()

func remove_self():
	queue_free()

func highlight_on():
	sprite.opacity = 0.5


func highlight_off():
	sprite.opacity = 1.0
