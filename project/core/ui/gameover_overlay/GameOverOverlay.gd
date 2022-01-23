extends PanelContainer


func show():
	$AnimationPlayer.play("show")


func restart_game():
	Global.start_new_game()
	
	
func exit_game():
	Global.exit_game()
