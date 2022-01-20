extends KinematicBody

signal danger_area_status
signal hold_changed
signal hold_size_changed

const ROTATION_TRANSITION = 2.0

export(NodePath) var navigation_node_path

onready var speed := 8.0
onready var boat_hold_capacity = 5
onready var navigation : Navigation = get_node(navigation_node_path)
onready var danger_position : Position3D = $Node/DangerPosition3D
onready var tween := $Tween
onready var gfx := $gfx

var points = 0
var pickup_candidate: Fish = null
var boat_hold := []
var danger_pool_timeout = 2.0
var current_move_direction = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("hold_size_changed", boat_hold_capacity)
	emit_signal("hold_changed", boat_hold)
	poll_danger_position()


func _physics_process(delta: float):
	if Input.is_action_just_pressed("pick_up") and pickup_candidate and can_pick_up_fish(pickup_candidate):
		pick_up_fish(pickup_candidate)
	update_fish_freshness(delta)
	handle_move()


func update_fish_freshness(delta: float):
	var remove_candidate_i: int
	var i := 0
	for fish in boat_hold:
		fish.time_to_deliver -= delta
		if fish.time_to_deliver <= 0:
			remove_candidate_i = i
		i += 1
	boat_hold.remove(remove_candidate_i)
	emit_signal("hold_changed", boat_hold)
			

func poll_danger_position():
	yield(get_tree().create_timer(danger_pool_timeout), "timeout")
	var path_to_danger_area = navigation.get_simple_path(global_transform.origin, danger_position.global_transform.origin)
	print("danger" if path_to_danger_area.size() > 0 else "safe")
	poll_danger_position()
	

func can_pick_up_fish(fish: Fish):
	return boat_hold.size() < boat_hold_capacity


func pick_up_fish(fish: Fish):
	boat_hold.append(fish.meta)
	emit_signal("hold_changed", boat_hold)
	fish.remove_self()


func _on_FishPickupArea_body_entered(fish: Fish):
	if pickup_candidate != fish:
		if pickup_candidate:
			pickup_candidate.highlight_off()
		pickup_candidate = fish
	if can_pick_up_fish(fish):
		fish.highlight_on()


func _on_FishPickupArea_body_exited(fish: Fish):
	if pickup_candidate == fish:
		pickup_candidate = null
	fish.highlight_off()


func handle_move():
	var move_direction = Vector3(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		0,
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)
	if move_direction.length() > 0 and move_direction != current_move_direction:
		rotate_unit(move_direction)
		current_move_direction = move_direction
	move_and_slide(move_direction.normalized() * speed, Vector3.UP)


func rotate_unit(move_direction):
	pass
#	var angle = atan2(move_direction.x, move_direction.z)
#	gfx.rotate_y(angle)	
#	tween.remove_all()
#	var angle = atan2(move_direction.x, move_direction.z)
#	var current_rotation = gfx.get_rotation()
#	current_rotation.y -= PI
#	var new_rotation = gfx.get_rotation()
#	new_rotation.y = angle - PI
#	print(current_rotation, new_rotation)
#	tween.interpolate_property(gfx, "rotation",
#		current_rotation, new_rotation, ROTATION_TRANSITION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	tween.start()


func _on_StockArea_body_entered(body: Stock):
	for fish_meta in boat_hold:
		points += fish_meta.value
	boat_hold.clear()
	print("CLEAR", points, boat_hold)
