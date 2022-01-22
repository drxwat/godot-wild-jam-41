extends StaticBody
class_name Fish
tool

export(Enums.FishType) var fish_type = Enums.FishType.BLUE

var meta: FishMeta
var fish_type_colors = {
	Enums.FishType.BLUE: Color(0, 0, 1),
	Enums.FishType.RED: Color(1, 0, 0),
	Enums.FishType.GOLD: Color(0, 1, 1)
}

var fish_type_time_to_deliver = {
	Enums.FishType.BLUE: 30,
	Enums.FishType.RED: 30,
	Enums.FishType.GOLD: 45
}

var fish_price = {
	Enums.FishType.BLUE: 8,
	Enums.FishType.RED: 8,
	Enums.FishType.GOLD: 25
}

var fish_type_meshes = {
	Enums.FishType.BLUE: preload("res://core/env_models/BlueFish.mesh"),
	Enums.FishType.RED: preload("res://core/env_models/BlueFish.mesh"),
	Enums.FishType.GOLD: preload("res://core/env_models/BlueFish.mesh"),
}


onready var particles := $Particles


func _ready():
	initialize(fish_type)
	particles.draw_pass_1 = fish_type_meshes.get(fish_type)
#	var material = SpatialMaterial.new()
#	material.albedo_color = fish_type_colors.get(fish_type)
#	particles.draw_pass_1.surface_set_material(0, material)


func initialize(_fish_type: int):
	fish_type = _fish_type
	meta = FishMeta.new(fish_price.get(fish_type), fish_type, fish_type_time_to_deliver.get(fish_type))

func remove_self():
	queue_free()

func highlight_on():
	pass

func highlight_off():
	pass
