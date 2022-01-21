extends PanelContainer

var fish_meta: FishMeta

var fish_images = {
	Enums.FishType.BLUE: preload("res://assets/ui/blue_fish.png"),
	Enums.FishType.RED: preload("res://assets/ui/red_fish.png")
}

var update_period := 1.0
var time_to_update := update_period

onready var texture_rect := $TextureRect
onready var ttl := $TTL

func _process(delta):
	if fish_meta:
		time_to_update -= delta
		if time_to_update <= 0:
			update_hold_element(fish_meta)
			time_to_update = update_period


func set_hold_element(_fish_meta: FishMeta):
	fish_meta = _fish_meta
	texture_rect.texture = fish_images[fish_meta.fish_type]
	ttl.text = String(floor(_fish_meta.time_to_deliver))


func update_hold_element(_fish_meta: FishMeta):
	ttl.text = String(floor(_fish_meta.time_to_deliver))


func clear_hold_element():
	fish_meta = null
	texture_rect.texture = null
	ttl.text = ''
