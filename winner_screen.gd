extends CenterContainer

onready var label = $PanelContainer/VBoxContainer/Label
onready var texture_rect = $PanelContainer/VBoxContainer/TextureRect

func _ready():
#	texture_rect.texture = load("res://Art/blue piece.png")
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	
func _on_button_button_up():
	get_tree().reload_current_scene()
	
