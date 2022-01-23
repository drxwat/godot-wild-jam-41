extends AudioStreamPlayer

var musicList = []

func _change_music() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	stream = musicList[rng.randi_range(0,6)]
	play()


func _ready() -> void:
	musicList.append(preload("res://sounds/soundtracks/gamejam-ost-circus-waltz.mp3"))
	musicList.append(preload("res://sounds/soundtracks/gamejam-ost-intro.mp3"))
	musicList.append(preload("res://sounds/soundtracks/gamejam-ost-main-theme-accordion.mp3"))
	musicList.append(preload("res://sounds/soundtracks/gamejam-ost-the-feeling-variation.mp3"))
	musicList.append(preload("res://sounds/soundtracks/gamejam-ost-the-feeling.mp3"))
	musicList.append(preload("res://sounds/soundtracks/gamejam-ost-the-loneliness.mp3"))
	musicList.append(preload("res://sounds/soundtracks/gamejam-ost-thriller-cover.mp3"))
	
	_change_music()





func _on_Soundtrack_finished() -> void:
	_change_music()
