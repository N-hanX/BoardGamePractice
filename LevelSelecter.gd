extends CenterContainer

onready var two = $PanelContainer/VBoxContainer/CenterContainer/GridContainer/Two

func _ready():
	if Events.board_two_enabled:
		two.disabled = false
		
	Fader.fade_in()

func _on_one_pressed():
	Fader.fade_out()
	get_tree().change_scene("res://PinkPiece.tscn")

func _on_two_pressed():
	Fader.fade_out()
	get_tree().change_scene("res://Main2.tscn")
