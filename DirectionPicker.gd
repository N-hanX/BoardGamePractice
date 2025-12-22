extends CenterContainer

func _on_Up_pressed():
	Events.emit_signal("picked_direction", Direction.UserPickedDirection.UP)
	queue_free()


func _on_Down_pressed():
	Events.emit_signal("picked_direction", Direction.UserPickedDirection.DOWN)
	queue_free()
