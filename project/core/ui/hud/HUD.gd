extends Control

var hold_element := preload("res://core/ui/hold_element/HoldElement.tscn")

onready var hold_container := $MarginContainer/VBoxContainer/Row1/HoldContainer
onready var fuel_bar := $MarginContainer/VBoxContainer/Row2/FuelBar
onready var money_label := $MarginContainer/VBoxContainer/Row1/Money/MoneyLabel

var hold 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	pass


func update_hold(_hold: Array):
	hold = _hold
	
	for i in hold_container.get_child_count():
		var hold_element = hold_container.get_child(i)
		if hold and hold.size() > i:
			var fish_meta = hold[i]
			hold_element.set_hold_element(fish_meta)
		else:
			hold_element.clear_hold_element()


func resize_hold(capacity: int):
	for child in hold_container.get_children():
		hold_container.remove_child(child)
	for i in range(capacity):
		var element = hold_element.instance()
		hold_container.add_child(element)


func update_fuel_level(fuel_tupple):
	fuel_bar.value = fuel_tupple[0]
	fuel_bar.max_value = fuel_tupple[1]


func update_money(money: int):
	money_label.text = String(money)
