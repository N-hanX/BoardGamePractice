extends Sprite

onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var timer: Timer = $Timer
signal dice_has_rolled(roll)
var can_click : bool = false # it might be true with some change

func _ready() -> void:
	randomize()
	Events.connect("can_click", self, "_on_can_click")
	
func _on_can_click():
	print("You can click dice now!")
	can_click = true

func roll():
	if Input.is_action_just_pressed("ui_click") and can_click:
		print("dice rolling")
		can_click = false
		animation_player.play("Roll")
		timer.start()


func _on_timer_timeout():
	var dice_roll : int = (randi() % 6) + 1
#	print(dice_roll)
	animation_player.play(str(dice_roll))
	emit_signal("dice_has_rolled", dice_roll)

	

