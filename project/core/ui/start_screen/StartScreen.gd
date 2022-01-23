extends CanvasLayer


func on_start_game():
	Global.start_new_game()


func on_exit_game():
	Global.exit_game()


func _on_Music_finished() -> void:
	$Music.play()
