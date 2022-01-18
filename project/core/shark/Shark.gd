extends KinematicBody

const ROTATION_TRANSITION = 0.1

export(NodePath) var navigation_node_path

var rng = RandomNumberGenerator.new()
var speed := 10

onready var navigation : Navigation = get_node(navigation_node_path)
onready var path_points: Node = $PathPoints
onready var tween = $Tween

var patroll_targets := []
var path: PoolVector3Array

func _ready():
	rng.randomize()
	patroll_targets = path_points.get_children()
	find_random_path()

func _process(delta: float):
	if not path.empty():
		_move_along_path()
	else:
		find_random_path()

func find_random_path():
	if patroll_targets.size() > 0:
		var next_point = patroll_targets[rng.randi_range(0, patroll_targets.size() - 1)]
		path = navigation.get_simple_path(global_transform.origin, next_point.global_transform.origin)

func _move_along_path() -> void:
	var move_vector: Vector3 = Vector3(path[0].x, 0, path[0].z) - Vector3(global_transform.origin.x, 0, global_transform.origin.z)
	if move_vector.length() < 0.1:
		path.remove(0)
	else:	
		_rotate_unit(move_vector)
		move_and_slide(move_vector.normalized() * speed, Vector3.UP)
		
func _rotate_unit(move_direction: Vector3):
	var angle = atan2(move_direction.x, move_direction.z)
	var new_rotation = get_rotation()
	new_rotation.y = angle
	tween.interpolate_property($".", "rotation",
		get_rotation(), new_rotation, ROTATION_TRANSITION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
