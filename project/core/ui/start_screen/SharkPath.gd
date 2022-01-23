extends Path

const SPEED := 10.0
var time: float

func _ready():
	time = curve.get_baked_length() / SPEED
	
	

func _physics_process(delta):
	$PathFollow.unit_offset += delta / time
