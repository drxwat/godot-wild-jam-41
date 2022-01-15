extends KinematicBody

onready var speed := 5.0
onready var boat_hold_capacity = 3

var points = 0
var pickup_candidate: Fish = null
var boat_hold := []

var directions = {
	Vector3(1, 0, 1): "move_down_right",
	Vector3(1, 0, 0): "move_right",
	Vector3(1, 0, -1): "move_top_right",
	Vector3(0, 0, -1): "move_top",
	Vector3(-1, 0, -1): "move_top_left",
	Vector3(-1, 0, 0): "move_left",
	Vector3(-1, 0, 1): "move_down_left",
	Vector3(0, 0, 1): "move_down"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta: float):
	if Input.is_action_just_pressed("pick_up") and pickup_candidate and can_pick_up_fish(pickup_candidate):
		pick_up_fish(pickup_candidate)
	handle_move()


func can_pick_up_fish(fish: Fish):
	return boat_hold.size() < boat_hold_capacity


func pick_up_fish(fish: Fish):
	boat_hold.append(fish.meta)
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
	if move_direction.length() > 0 and directions.has(move_direction):
		$Sprite3D.play(directions.get(move_direction))
	move_and_slide(move_direction.normalized() * speed, Vector3.UP)


func _on_StockArea_body_entered(body: Stock):
	for fish_meta in boat_hold:
		points += fish_meta.value
	boat_hold.clear()
	print("CLEAR", points, boat_hold)
