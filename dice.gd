extends Sprite

onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var timer: Timer = $Timer
signal dice_has_rolled(roll)
var can_click : bool = true

func _ready() -> void:
	randomize()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_click") and can_click:
		can_click = false
		animation_player.play("Roll")
		timer.start()


func _on_timer_timeout():
	var dice_roll : int = (randi() % 6) + 1
#	print(dice_roll)
	animation_player.play(str(dice_roll))
	emit_signal("dice_has_rolled", dice_roll)
	

