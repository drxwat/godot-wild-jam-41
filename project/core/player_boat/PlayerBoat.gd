extends KinematicBody

const FUEL_PENALTY = 340
const SHARK_PENALTY = 300
const COLOR_BONUS_EXP = 1.8

signal area_changed
signal hold_changed
signal hold_size_changed
signal fuel_level_changed
signal points_changed
signal wasted
signal game_over

const ROTATION_TRANSITION = 0.2
const FUEL_EMIT_PERIOD = 1.0
const LOW_FUEL_SPEED_MOD = 0.7
const LOW_FUEL_BOUNDARY = 0.2

export(NodePath) var navigation_node_path

onready var speed := 10.0
onready var boat_hold_capacity = 5
onready var navigation : Navigation = get_node(navigation_node_path)
onready var danger_position : Position3D = $Node/DangerPosition3D
onready var tween := $Tween
onready var gfx := $gfx
onready var engine_noise := $EngineNoise
onready var text_popup := $TextPopup

var is_disabled := false
var points = 500
var boat_hold := []
var danger_pool_timeout = 0.5
var current_move_direction = Vector3.ZERO
var max_fuel_time := 120.0
var fuel = max_fuel_time / 3
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
	if is_disabled:
		return
	update_fish_freshness(delta)
	if gas_station and fuel < max_fuel_time and points > 0:
		buy_fuel(delta)
	
	if Input.is_action_pressed("ui_up") or \
	Input.is_action_pressed("ui_down") or \
	Input.is_action_pressed("ui_right") or \
	Input.is_action_pressed("ui_left"):
		is_moving = true
	else:
		is_moving = false
	
	sound_process()
	handle_move(delta)

func buy_fuel(delta: float):
	var fuel_to_buy = ceil(delta * fuel_buying_speed)
	var fuel_price = fuel_to_buy * gas_station.fuel_price
	fuel += fuel_to_buy
	points -= fuel_price
	emit_signal("fuel_level_changed", [fuel, max_fuel_time])
	emit_signal("points_changed", points)

func die_from_shark():
	is_disabled = true
	if points >= SHARK_PENALTY:
		emit_signal("wasted", "ROBED BY SHARK", points, SHARK_PENALTY)

func respawn(position: Vector3, penalty: int):
	is_disabled = false
	global_transform.origin = position
	print("points", points, "penalty", penalty)
	points -= penalty
	fuel = max_fuel_time
	boat_hold.clear()
	emit_signal("fuel_level_changed", [fuel, max_fuel_time])
	emit_signal("hold_changed", boat_hold)
	emit_signal("points_changed", points)


func sound_process():
	if is_moving and not engine_noise.playing:
		engine_noise.play()
	elif not is_moving and engine_noise.playing:
		engine_noise.stop()


func update_fish_freshness(delta: float):
	var remove_candidate_i = null
	var i := 0
	for fish in boat_hold:
		fish.time_to_deliver -= delta
		if fish.time_to_deliver <= 0:
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
	emit_signal("hold_changed", boat_hold)
	fish.remove_self()


func _on_FishPickupArea_body_entered(fish: Fish):
	if can_pick_up_fish(fish):
		pick_up_fish(fish)


func handle_move(delta: float):
	var move_direction = Vector3(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		0,
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)
	if move_direction.length() > 0 and move_direction != current_move_direction:
		rotate_unit(move_direction)
		current_move_direction = move_direction

	var fuel_modifier = LOW_FUEL_SPEED_MOD if fuel / max_fuel_time <= LOW_FUEL_BOUNDARY else 1.0
	if engine_noise.pitch_scale != fuel_modifier:
		engine_noise.pitch_scale = fuel_modifier
	if move_direction.length() > 0:
		burn_fuel(delta * fuel_modifier)
	if fuel > 0:
		move_and_slide(move_direction.normalized() * speed * fuel_modifier, Vector3.UP)


func burn_fuel(delta: float):
	fuel -= delta
	emit_fuel_change -= delta
	if emit_fuel_change <= 0:
		emit_signal("fuel_level_changed", [fuel, max_fuel_time])
	if fuel <= 0 and points > FUEL_PENALTY:
		emit_signal("wasted", "OUT OF FUEL", points, FUEL_PENALTY)
		is_disabled = true
	elif fuel <= 0:
		emit_signal("game_over")
		is_disabled = true


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



func stock_fish(stock: Stock):
	var sold_sum = 0
	var color_bonuses := {
		
	}
	for fish_meta in boat_hold.duplicate():
		if stock.is_universal or stock.stock_fish_type == fish_meta.fish_type:
			points += fish_meta.value
			sold_sum += fish_meta.value
			boat_hold.erase(fish_meta)
			if color_bonuses.has(fish_meta.fish_type):
				color_bonuses[fish_meta.fish_type] += 1
			else:
				color_bonuses[fish_meta.fish_type] = 0
	var bonus = 0
	for color_bonus_amount in color_bonuses.values():
		bonus += ceil(pow(color_bonus_amount, COLOR_BONUS_EXP))
	if sold_sum > 0:
		emit_signal("hold_changed", boat_hold)
		emit_signal("points_changed", points)
		var text = "PROFIT %s$ + COLOR BONUS %s$" % [sold_sum, bonus] if bonus > 0 else "PROFIT %s$" % [sold_sum]
		text_popup.pop_up(text)
		
	

