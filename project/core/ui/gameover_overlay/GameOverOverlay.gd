extends PanelContainer


func show_overlay():
	print("GAME OVER")
	show()
	$AnimationPlayer.play("show")


func restart_game():
	Global.start_new_game()
	
	
func exit_game():
	Global.exit_game()
