extends Spatial

onready var player := $PlayerBoat
onready var wasted_overlay := $UI/WastedOverlay
onready var alarm := $Alarm

var initial_position = Vector3(118.777, 0.413, 212.549)

func _ready():
	for shark in get_tree().get_nodes_in_group("sharks"):
		shark.connect("chasing", self, "on_shark_chasing")
		shark.connect("lose_target", self, "on_shark_lose_target")
	player.connect("fuel_buy_in_progress", self, "on_fuel_buy_start")
	player.connect("fuel_buy_end", self, "on_fuel_buy_stop")
	player.connect("fish_sold", self, "on_fish_sell")
	player.connect("fish_picked_up", self, "on_fish_pick_up")


func on_wasted(reason: String, _money: int, _penalty: int):
	if not $GameOver.playing:
		$GameOver.play()
	
	wasted_overlay.show_overlay(reason, _money, _penalty)
	yield(wasted_overlay, "penalty_finished")
	player.respawn(initial_position, _penalty)
	yield(get_tree().create_timer(1.0), "timeout")
	wasted_overlay.hide_overlay()


func on_shark_chasing():
	if not alarm.playing:
		alarm.play()
	
	
func on_shark_lose_target():
	if alarm.playing:
		alarm.stop()


func on_fuel_buy_start():
	if not $Fuel.playing:
		$Fuel.play()
	

func on_fuel_buy_stop():
	if $Fuel.playing:
		$Fuel.stop()
	

func on_fish_sell():
	if not $SaleOfFish.playing:
		$SaleOfFish.play()

func on_fish_pick_up():
	if not $FishSound.playing:
		$FishSound.play()
