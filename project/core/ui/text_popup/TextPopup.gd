extends Sprite3D


func pop_up(text: String):
	$Viewport/Label.text = text
	$AnimationPlayer.play("pop_up")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("RESET")
	
