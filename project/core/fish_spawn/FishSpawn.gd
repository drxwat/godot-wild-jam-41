extends Spatial

export var spawn_time_base := 3.0
export var spawn_time_deviation := 2.0
export var radius := 10.0

var rng = RandomNumberGenerator.new()
var fish_scene = preload("res://core/fish/Fish.tscn")

func _ready():
	$MeshInstance.mesh.top_radius = radius
	rng.randomize()
	spawn_fish()


func spawn_fish():
	var timeout = spawn_time_base + rng.randf_range(-spawn_time_deviation, spawn_time_deviation)
	yield(get_tree().create_timer(timeout), "timeout")
	var fish_type = rng.randi_range(0, Enums.FishType.size() - 1)
	var spawn_radius = rng.randf_range(0.0, radius)
	var fish_origin = Vector3(rng.randf_range(-1.0, 1.0), 0.0, rng.randf_range(-1.0, 1.0)).normalized() * spawn_radius
	var fish = fish_scene.instance()
	fish.initialize(fish_type)
	fish.transform.origin = fish_origin
	add_child(fish)
	spawn_fish()

