extends PanelContainer

const PENALTY_DELAY := 1.0
const PENALTY_TIME := 3.0

signal penalty_finished

onready var particles := $Particles2D
onready var money_label := $CenterContainer/VBoxContainer/HBoxContainer/Money
onready var reason_label := $CenterContainer/VBoxContainer/ReasonLabel


var is_penalty_in_progress := false
var time_to_penalty := PENALTY_DELAY
var penalty_interpolation := 0.0
var money: int
var penalty: int

func _process(delta):
	if is_penalty_in_progress:
		time_to_penalty -= delta
		if time_to_penalty <= 0:
			penalty_interpolation += delta / PENALTY_TIME
			money_label.text = String(money - (penalty * penalty_interpolation))
		if penalty_interpolation >= 1.0:
			is_penalty_in_progress = false
			emit_signal("penalty_finished")


func show_overlay(reason: String, _money: int, _penalty: int):
	show()
	money = _money
	penalty = _penalty
	time_to_penalty = PENALTY_DELAY
	penalty_interpolation = 0.0
	particles.emitting = true
	money_label.text = String(_money)
	reason_label.text = reason
	is_penalty_in_progress = true


func hide_overlay():
	hide()
	particles.emitting = false
