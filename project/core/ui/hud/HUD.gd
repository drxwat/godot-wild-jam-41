extends Control

var hold_element := preload("res://core/ui/hold_element/HoldElement.tscn")

onready var hold_container := $MarginContainer/VBoxContainer/Row1/HoldContainer
var hold 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	pass


func update_hold(_hold: Array):
	hold = _hold
	for i in range(hold.size()):
		var fish_meta = hold[i]
		var hold_element = hold_container.get_child(i)
		hold_element.fish_meta = fish_meta


func resize_hold(capacity: int):
	for child in hold_container.get_children():
		hold_container.remove_child(child)
	for i in range(capacity):
		var element = hold_element.instance()
		hold_container.add_child(element)
