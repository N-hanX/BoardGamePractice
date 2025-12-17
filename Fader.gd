extends CanvasLayer
onready var animation_player = $AnimationPlayer

func fade_out():
	animation_player.play("fade")
	
func fade_in():
	animation_player.play_backwards("fade")
