extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func on_start_game():
	print("START_GAME")


func _on_Area_input_event(camera, event, position, normal, shape_idx):
	print('INPUT')
