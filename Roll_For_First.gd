extends CenterContainer
onready var animation_player = $AnimationPlayer
onready var timer = $Timer
onready var label = $PanelContainer/VBoxContainer/Label
onready var texture_rect = $PanelContainer/VBoxContainer/TextureRect
onready var button = $PanelContainer/VBoxContainer/Button
onready var go_away_timer = $GoAwayTimer

func _ready() -> void:
	randomize()

func _on_button_button_down():
	animation_player.play("coin_flip")
	timer.start()
	button.hide()
	
			
func _on_timer_timeout():
	var piece_roll : int = (randi() % 2) + 1
	animation_player.stop(false)
	match piece_roll:
		1: 
			label.text = "Pink piece!"
			texture_rect.texture = load("res://Art/pink piece.png")
		2:
			label.text = "Blue piece!"
			texture_rect.texture = load("res://Art/blue piece.png")
	
	go_away_timer.start()


func _on_goAwayTimer_timeout():
	hide()
