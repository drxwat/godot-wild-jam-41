extends Control

var hold_element := preload("res://core/ui/hold_element/HoldElement.tscn")

onready var hold_container := $MarginContainer/VBoxContainer/CenterContainer/Row1/PanelContainer2/MarginContainer/HoldContainer
onready var fuel_bar := $MarginContainer/VBoxContainer/CenterContainer/Row1/PanelContainer/MarginContainer/PanelContainer/FuelBar
onready var money_label := $MarginContainer/VBoxContainer/CenterContainer/Row1/PanelContainer3/MarginContainer/PanelContainer/MoneyLabel
onready var tween := $Tween
onready var area_label := $MarginContainer/VBoxContainer/TopBar/AreaLabel

var hold
var green_color := Color('#1aab00')
var red_color := Color('#ab0000')

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
	fuel_bar.tint_progress = red_color.linear_interpolate(green_color, fuel_tupple[0] / fuel_tupple[1])


func update_money(money: int):
	money_label.text = String(money)
#	tween.interpolate_property(money_label, "text", money_label.text, String(money), 1.0)
#	tween.start()


func change_area(area_type: int):
	area_label.text = "SAFE AREA" if area_type == Enums.AreaType.SAFE else "DANGER AREA"
	area_label.add_color_override("font_color", green_color if area_type == Enums.AreaType.SAFE else red_color)
