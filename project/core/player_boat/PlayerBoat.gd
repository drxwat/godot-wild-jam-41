extends KinematicBody

const FUEL_PENALTY = 240

signal area_changed
signal hold_changed
signal hold_size_changed
signal fuel_level_changed
signal points_changed
signal wasted
signal game_over

const ROTATION_TRANSITION = 0.2
const FUEL_EMIT_PERIOD = 1.0

export(NodePath) var navigation_node_path

onready var speed := 10.0
onready var boat_hold_capacity = 5
onready var navigation : Navigation = get_node(navigation_node_path)
onready var danger_position : Position3D = $Node/DangerPosition3D
onready var tween := $Tween
onready var gfx := $gfx

var points = 500
var pickup_candidate: Fish = null
var boat_hold := []
var danger_pool_timeout = 0.5
var current_move_direction = Vector3.ZERO
var max_fuel_time := 120.0
var fuel = max_fuel_time / 2
var emit_fuel_change = FUEL_EMIT_PERIOD
var danger_area = Enums.AreaType.SAFE
var gas_station

var is_moving: bool = false

var fuel_buying_speed = 50.0
var fuel_bought = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("hold_size_changed", boat_hold_capacity)
	emit_signal("hold_changed", boat_hold)
	emit_signal("fuel_level_changed", [fuel, max_fuel_time])
	emit_signal("points_changed", points)
	emit_signal("area_changed", danger_area)
	poll_danger_position()


func _physics_process(delta: float):
	update_fish_freshness(delta)
	if Input.is_action_pressed("pick_up") and gas_station and fuel < max_fuel_time and points > 0:
		var fuel_to_buy = ceil(delta * fuel_buying_speed)
		var fuel_price = fuel_to_buy * gas_station.fuel_price
		fuel += fuel_to_buy
		points -= fuel_price
		print(fuel_to_buy, fuel_price)
		emit_signal("fuel_level_changed", [fuel, max_fuel_time])
		emit_signal("points_changed", points)
		return
	elif Input.is_action_just_pressed("pick_up") and pickup_candidate and can_pick_up_fish(pickup_candidate):
		pick_up_fish(pickup_candidate)
	
	if Input.is_action_pressed("ui_up") or \
	Input.is_action_pressed("ui_down") or \
	Input.is_action_pressed("ui_right") or \
	Input.is_action_pressed("ui_left"):
		is_moving = true
	else:
		is_moving = false
	
	sound_process()
	handle_move(delta)


func sound_process():
	if is_moving and not $EngineNoise.playing:
		$EngineNoise.play()
	elif not is_moving and $EngineNoise.playing:
		$EngineNoise.stop()


func update_fish_freshness(delta: float):
	var remove_candidate_i = null
	var i := 0
	for fish in boat_hold:
		fish.time_to_deliver -= delta
		if fish.time_to_deliver <= 0:
			print("candidate to remove")
			remove_candidate_i = i
		i += 1
	if remove_candidate_i != null:
		boat_hold.remove(remove_candidate_i)
		emit_signal("hold_changed", boat_hold)
			

func poll_danger_position():
	yield(get_tree().create_timer(danger_pool_timeout), "timeout")
	var path_to_danger_area = navigation.get_simple_path(global_transform.origin, danger_position.global_transform.origin)
	var new_area = Enums.AreaType.DANGER if path_to_danger_area.size() > 0 else Enums.AreaType.SAFE
	if new_area != danger_area:
		danger_area = new_area
		emit_signal("area_changed", danger_area)
	poll_danger_position()
	

func can_pick_up_fish(fish: Fish):
	return boat_hold.size() < boat_hold_capacity


func pick_up_fish(fish: Fish):
	boat_hold.append(fish.meta)
	print(boat_hold.size())
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


func handle_move(delta: float):
	var move_direction = Vector3(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		0,
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)
	if move_direction.length() > 0 and move_direction != current_move_direction:
		rotate_unit(move_direction)
		current_move_direction = move_direction
	if move_direction.length() > 0:
		burn_fuel(delta)
	move_and_slide(move_direction.normalized() * speed, Vector3.UP)


func burn_fuel(delta: float):
	fuel -= delta
	emit_fuel_change -= delta
	if emit_fuel_change <= 0:
		emit_signal("fuel_level_changed", [fuel, max_fuel_time])
	if fuel <= 0 and points > FUEL_PENALTY:
		emit_signal("wasted", "OUT OF FUEL", points, FUEL_PENALTY)
	elif fuel <= 0:
		emit_signal("game_over")


func rotate_unit(move_direction):
	var angle = rad2deg(atan2(move_direction.x, move_direction.z))
	var rotation = gfx.rotation_degrees.y - angle
	if rotation > 180:
		angle = angle + 360
	elif rotation < -180:
		angle = angle - 360
	tween.interpolate_property(gfx, "rotation_degrees:y", gfx.rotation_degrees.y, angle, ROTATION_TRANSITION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_StockArea_body_entered(body: StaticBody):
	if body is Stock:
		stock_fish(body)
	if body is GasStation:
		gas_station = body



func _on_StockGasArea_body_exited(body: StaticBody):
	if body is GasStation:
		gas_station = null


func buy_fuel(body: GasStation):
	pass


func stock_fish(stock: Stock):
	var has_sold_something = false
	for fish_meta in boat_hold.duplicate():
		if stock.is_universal or stock.stock_fish_type == fish_meta.fish_type:
			points += fish_meta.value
			boat_hold.erase(fish_meta)
			has_sold_something = true
	if has_sold_something:
		emit_signal("hold_changed", boat_hold)
		emit_signal("points_changed", points)
	

