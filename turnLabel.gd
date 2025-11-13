extends PanelContainer

onready var label: Label = $Label
onready var timer: Timer = $Timer

func _ready():
	timer.start()
	

func _on_timer_timeout():
	hide()
