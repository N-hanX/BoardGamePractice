extends Camera2D


#export(NodePath) var target_path
export(NodePath) var top_left_limit_path
export(NodePath) var bottom_right_limit_path

#onready var target = get_node(target_path)
onready var top_left = get_node(top_left_limit_path)
onready var bottom_right = get_node(bottom_right_limit_path)
var transitioning : bool = false


func _ready():
	# Set camera limits using GLOBAL coordinates
	limit_left   = top_left.global_position.x
	limit_top    = top_left.global_position.y
	limit_right  = bottom_right.global_position.x
	limit_bottom = bottom_right.global_position.y
	self.current = false
	

func transition_camera2D(from: Camera2D, to: Camera2D, currentPiecePosition: Sprite):
	print("transitioning: ", transitioning)
	if transitioning: return

	# transitioning steps
	#turn this camera current and turn the current camera off

	self.global_position = currentPiecePosition.position

	transitioning = true
	
	from.current = false
	# 🔑 Wait one frame so THIS camera becomes active
	yield(get_tree(), "idle_frame")
	self.current = true

	
	#move this camera
	var tween = Tween.new() # Create a new Tween node
	add_child(tween)
	
	var transition_speed = 1
	# move camera
	tween.interpolate_property(self, "global_position", self.global_position, to.global_position, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start() 	# Start the tween
	yield(tween, "tween_completed") # Wait until the tween completes
	

	#zoom in first
	var zoomed = Vector2(0.5, 0.5)
	var normal = Vector2(1, 1)
	
	var zoomedin_tween = Tween.new()
	add_child(zoomedin_tween)
	zoomedin_tween.interpolate_property(self, "zoom", normal, zoomed, transition_speed, Tween.TRANS_SINE, Tween.EASE_OUT)
	zoomedin_tween.start() 	# Start the tween
	yield(zoomedin_tween, "tween_completed") # Wait until the tween completes
	
	# zoom out back to normal 
	var zoomedout_tween = Tween.new()
	add_child(zoomedout_tween)
	zoomedout_tween.interpolate_property(self, "zoom", zoomed, normal, transition_speed, Tween.TRANS_SINE, Tween.EASE_IN)
	zoomedout_tween.start()
	yield(zoomedout_tween, "tween_completed")
	
	#turn this camera off and the turn the next camera on
	self.current = false
	to.current = true
	
	transitioning = false
	
	tween.queue_free()
	zoomedin_tween.queue_free()
	zoomedout_tween.queue_free()
