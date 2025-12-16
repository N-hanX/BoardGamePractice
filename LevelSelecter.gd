extends CenterContainer

onready var two = $PanelContainer/VBoxContainer/CenterContainer/GridContainer/Two

func _ready():
	if Events.board_two_enabled:
		two.disabled = false

func _on_one_pressed():
	get_tree().change_scene("res://PinkPiece.tscn")

func _on_two_pressed():
	get_tree().change_scene("res://Main2.tscn")
