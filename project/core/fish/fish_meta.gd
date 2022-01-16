extends Reference
class_name FishMeta

var value
var fish_type
var time_to_deliver

func _init(_value = 6, _fish_type = Enums.FishType.BLUE, _time_to_deliver = 30):
	value = _value
	fish_type = _fish_type
	time_to_deliver = _time_to_deliver
