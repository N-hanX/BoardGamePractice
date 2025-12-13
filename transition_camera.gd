extends Camera2D


#export(NodePath) var target_path
export(NodePath) var top_left_limit_path
export(NodePath) var bottom_right_limit_path

#onready var target = get_node(target_path)
onready var top_left = get_node(top_left_limit_path)
onready var bottom_right = get_node(bottom_right_limit_path)
var transitioning : bool = false
export var transition_speed = 1
export var zoom_amount = Vector2(1.5, 1.5)


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
	self.zoom = from.zoom
	self.offset = from.offset

	self.limit_left   = from.limit_left
	self.limit_top    = from.limit_top
	self.limit_right  = from.limit_right
	self.limit_bottom = from.limit_bottom

	self.global_position = currentPiecePosition.position

	transitioning = true
	
	from.current = false
	yield(get_tree(), "idle_frame")
	self.current = true
	
		# 🔑 Wait one frame so THIS camera becomes active
	yield(get_tree(), "idle_frame")
	
	#move this camera
	var tween = Tween.new() # Create a new Tween node
	add_child(tween)
	
	# move camera
	tween.interpolate_property(self, "global_position", self.global_position, to.global_position, transition_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	#zoom in first
#	tween.interpolate_property(self, "zoom", self.zoom, zoom_amount, transition_speed)
	tween.start() 	# Start the tween
	yield(tween, "tween_completed") # Wait until the tween completes
	
	# zoom out back to normal 
#	var tween2 = Tween.new()
#	add_child(tween2)
#	tween2.interpolate_property(self, "zoom", self.zoom, Vector2(1,1), transition_speed)
#	tween2.start()
#	yield(tween2, "tween_completed")
#	tween.queue_free()
#	tween2.queue_free()
	
	#turn this camera off and the turn the next camera on
	self.current = false
	to.current = true
	
	transitioning = false
	
