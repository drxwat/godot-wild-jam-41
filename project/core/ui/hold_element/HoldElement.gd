extends TextureRect

var fish_meta: FishMeta

func _process(delta):
	if fish_meta:
		print(fish_meta)
