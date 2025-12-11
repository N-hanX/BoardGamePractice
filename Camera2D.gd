extends Camera2D

export(NodePath) var target_path
export(NodePath) var top_left_limit_path
export(NodePath) var bottom_right_limit_path

onready var target = get_node(target_path)
onready var top_left = get_node(top_left_limit_path)
onready var bottom_right = get_node(bottom_right_limit_path)

func _ready():
	# Set camera limits using GLOBAL coordinates
	limit_left   = top_left.global_position.x
	limit_top    = top_left.global_position.y
	limit_right  = bottom_right.global_position.x
	limit_bottom = bottom_right.global_position.y
	
func _process(delta):
	# Follow object in world space
	global_position = target.global_position
