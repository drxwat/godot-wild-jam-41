extends Spatial
tool


export var spawn_time_deviation := 2.0
export var radius := 10.0

var rng = RandomNumberGenerator.new()
var fish_scene = preload("res://core/fish/Fish.tscn")
var spawn_time_radius_fraction := 400.0
var max_amount_raduis_fraction := 0.2
var max_fish: int

onready var fish_container := $FishContainer

func _ready():
	$MeshInstance.mesh = CylinderMesh.new()
	$MeshInstance.mesh.top_radius = radius
	max_fish = ceil(radius * max_amount_raduis_fraction)
	if !Engine.is_editor_hint():
		rng.randomize()
		spawn_fish()
		
		
func _process(delta):
	if Engine.is_editor_hint():
		$MeshInstance.mesh.top_radius = radius


func spawn_fish():
	var spawn_time_base = spawn_time_radius_fraction / radius
	var timeout = spawn_time_base + rng.randf_range(-spawn_time_deviation, spawn_time_deviation)
	yield(get_tree().create_timer(timeout), "timeout")
	if fish_container.get_child_count() >= max_fish:
		return
	var fish_type = rng.randi_range(0, Enums.FishType.size() - 1)
	var spawn_radius = rng.randf_range(0.0, radius)
	var fish_origin = Vector3(rng.randf_range(-1.0, 1.0), 0.0, rng.randf_range(-1.0, 1.0)).normalized() * spawn_radius
	var fish = fish_scene.instance()
	fish.initialize(fish_type)
	fish.transform.origin = fish_origin
	fish_container.add_child(fish)
	spawn_fish()

