extends KinematicBody

signal chasing
signal lose_target

const ROTATION_TRANSITION = 0.1
const PATH_TO_TARGET_PERIOD = 0.8

export(NodePath) var navigation_node_path

var rng = RandomNumberGenerator.new()
var speed := 4.0
var chase_speed := 9.0

onready var navigation : Navigation = get_node(navigation_node_path)
onready var path_points: Node = $PathPoints
onready var tween = $Tween

var patroll_targets := []
var path: PoolVector3Array
var target: Spatial
var is_target_reachable := false
var time_to_path_find = PATH_TO_TARGET_PERIOD

func _ready():
	rng.randomize()
	patroll_targets = path_points.get_children()
	find_random_path()

func _process(delta: float):
	if target:
		time_to_path_find -= delta
		if time_to_path_find <= 0:
			time_to_path_find = PATH_TO_TARGET_PERIOD
			var path_to_target = navigation.get_simple_path(global_transform.origin, target.global_transform.origin)
			if path_to_target.size() > 0:
				is_target_reachable = true
				emit_signal("chasing")
			else:
				is_target_reachable = false
				emit_signal("lose_target")
	if target and is_target_reachable:
		chase_target()
		return
#	elif target and not path.empty(): # not_reachable
#		find_return_path(path)
#
	if not path.empty():
		_move_along_path()
	else:
		find_random_path()

func chase_target():
	if target.is_disabled:
		target = null
		return
	var move_vector = global_transform.origin.direction_to(target.global_transform.origin)
	_rotate_unit(move_vector)
	move_and_slide(move_vector.normalized() * chase_speed, Vector3.UP)

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


func find_return_path(old_path: PoolVector3Array):
	var destination_point = old_path[old_path.size() - 1]
	var new_path = navigation.get_simple_path(global_transform.origin, destination_point)
	if new_path.size() > 0:
		path = new_path

func _on_AttackArea_body_entered(player):
	emit_signal("chasing")
	target = player


func _on_AttackArea_body_exited(body):
	target = null
	emit_signal("lose_target")


func _on_RobArea_body_entered(body: Spatial):
	if body.has_method("die_from_shark"):
		body.die_from_shark()
		target = null
		emit_signal("lose_target")
