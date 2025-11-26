extends CenterContainer

export var button_one_is_right : bool
onready var label: Label = $PanelContainer/MarginContainer/VBoxContainer/Label
onready var hbox_container: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer
var right_or_wrong : bool
onready var audio_stream_player = $AudioStreamPlayer
var start = load("res://Audio/board game question comes up.wav")
var right = load("res://Audio/board game question right.wav")
var wrong = load("res://Audio/board game question wrong.wav")

func _ready():
	audio_stream_player.stream = start
	audio_stream_player.play()

func _on_button_pressed():
	if button_one_is_right:
		question_is_right()
	else:
		question_is_wrong()

func _on_button2_pressed():
	if !button_one_is_right:
		question_is_right()
	else:
		question_is_wrong()
		
func _input(event: InputEvent):
	if hbox_container.visible == false and Input.is_action_just_pressed("ui_click"):
		Events.emit_signal("question_box_gone", right_or_wrong)
		queue_free()

	
func question_is_right():
	audio_stream_player.stream = right
	audio_stream_player.play()
	label.text = "You got it right!"
	hbox_container.hide()
	right_or_wrong = true
	
func question_is_wrong():
	audio_stream_player.stream = wrong
	audio_stream_player.play()
	label.text = "That isn't right, sorry"
	hbox_container.hide()
	right_or_wrong = false
