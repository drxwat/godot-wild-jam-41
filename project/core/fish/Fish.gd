extends StaticBody
class_name Fish
tool

export(Enums.FishType) var fish_type = Enums.FishType.BLUE

var meta: FishMeta
var fish_type_colors = {
	Enums.FishType.BLUE: Color(0, 0, 1),
	Enums.FishType.RED: Color(1, 0, 0)
}

onready var particles := $Particles


func _ready():
	initialize(fish_type)
	var material = SpatialMaterial.new()
	material.albedo_color = fish_type_colors.get(fish_type)
	particles.draw_pass_1.surface_set_material(0, material)


func initialize(_fish_type: int):
	fish_type = _fish_type
	meta = FishMeta.new(6, fish_type)

func remove_self():
	queue_free()

func highlight_on():
	pass

func highlight_off():
	pass
