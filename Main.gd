extends Node2D

onready var pink_piece : Sprite = $PinkPiece
onready var blue_piece : Sprite = $BluePiece
export(Array, NodePath) var game_spaces_paths
#export var question_boxes : Array[PackedScene]
export(Array, PackedScene) var question_boxes
var game_spaces : Array = [Spot]
var place : int = 1
onready var dice = $CanvasLayer/Dice
onready var timer := $Timer
onready var canvas_layer: CanvasLayer = $CanvasLayer
var score : int = 0
onready var score_label: Label = $CanvasLayer/Score
var pink_piece_turn : bool = true
onready var turn_label: PanelContainer = $CanvasLayer/TurnLabel
onready var winner__screen: CenterContainer = $"CanvasLayer/Winner Screen"
onready var piece
onready var audio_stream_player = $AudioStreamPlayer
onready var camera_2d__pink_piece = $Camera2D_PinkPiece
onready var camera_2d__blue_piece = $Camera2D_BluePiece
onready var transition_camera = $TransitionCamera
var piece_is_moving := false
export var board_number : int
var counter = 0;
export var bounceback_board : bool

func _ready():
	game_spaces.clear()
	for path in game_spaces_paths:
		var node = get_node(path)
		if node and node is Position2D:
			game_spaces.append(node)
			

	Events.connect("question_box_gone", self, "_on_question_box_gone")
#	piece = pink_piece # just initilization
	Events.connect("send_piece", self,"_on_send_piece")
	Fader.fade_in()

	
func _input(event: InputEvent) -> void: # now signaling changed from dice 
	whose_turn_is_it()
		
	if event.is_action_pressed("ui_click") and dice.can_click == true:
		if piece.i_won == false:
			dice.roll()
		else:
			pink_piece_turn = !pink_piece_turn
			turn_label_switcher()
			
func whose_turn_is_it():
	if pink_piece_turn: # and signal change require to trigger it
		piece = pink_piece
#		camera_2d__pink_piece.current = true
#		camera_2d__blue_piece.current = false
	else:
		piece = blue_piece	
#		camera_2d__pink_piece.current = false
#		camera_2d__blue_piece.current = true	

func _on_dice_dice_has_rolled(roll) -> void:
#	print(roll)
	roll = 25# for testing there is a bug backward
#	
#	if piece == pink_piece: roll = 20 # specific case test fix:  dice still rolling illogically

#	if counter == 0:
#		roll = 1
#
#	if counter == 1:
#		roll = 5
#
#	counter = counter + 1
	
	if blue_piece.place  >= game_spaces.size() - 1 and pink_piece.place >= game_spaces.size() - 1:
		# if both of these pieces are at the winner's circle
		winner__screen.visible = true	
		winner__screen.board_that_called_me = board_number
		if pink_piece.score > blue_piece.score:
			winner__screen.label.text = "Pink won!"
			winner__screen.texture_rect.texture = load("res://Art/pink piece.png")
		elif blue_piece.score > pink_piece.score:
			winner__screen.label.text = "Blue won!"
			winner__screen.texture_rect.texture = load("res://Art/blue piece.png")
		else:
			print("both won")
			winner__screen.label.text = "It is a tie!"
			winner__screen.texture_rect.texture = load("res://Art/both.png")
		return
	
	while roll > 0:
		if piece.place < game_spaces.size():
			# if we've not won
			move(piece, piece.place)
			timer.start()                      
			yield(timer, "timeout")     
	#		print("MOVE REGULAR ")       
			piece.place += 1
			roll -= 1
			print("moving to: ", piece.place)
		else:
			# if we've won
			if blue_piece.place  >= game_spaces.size() - 1 and pink_piece.place >= game_spaces.size() - 1:
				# if both of these pieces are at the winner's circle
				winner__screen.visible = true	
				winner__screen.board_that_called_me = board_number
				if pink_piece.score > blue_piece.score:
					winner__screen.label.text = "Pink won!"
					winner__screen.texture_rect.texture = load("res://Art/pink piece.png")
				elif blue_piece.score > pink_piece.score:
					winner__screen.label.text = "Blue won!"
					winner__screen.texture_rect.texture = load("res://Art/blue piece.png")
				else:
					print("both won")
					winner__screen.label.text = "It is a tie!"
					winner__screen.texture_rect.texture = load("res://Art/both.png")
				break
			else:
				# if just one is at the winner's circle
				if roll > 0 and bounceback_board == true:
					print('bounce back is active')
					bounceback(roll)
					print('end of bounce back')
					return
				
				print('end of game space')	
				piece.place = game_spaces.size()
				piece.i_won = true
				dice.can_click = true
#				pink_piece_turn = !pink_piece_turn
				turn_label_switcher()
				return		
	if roll == 0: # signs of stop the move
		print('last step of roll')
		if piece.place >= game_spaces.size():	
			dice.can_click = true
			turn_label_switcher()
			return
		
		move(piece, piece.place)
		timer.start()                      
		yield(timer, "timeout")     
#		print("MOVE REGULAR for roll = 0 ")    
		if blue_piece.place >= game_spaces.size() - 1 and pink_piece.place >= game_spaces.size() - 1:
			# if both of these pieces are at the winner's circle
			winner__screen.visible = true	
			winner__screen.board_that_called_me = board_number
			if pink_piece.score > blue_piece.score:
				winner__screen.label.text = "Pink won!"
				winner__screen.texture_rect.texture = load("res://Art/pink piece.png")
			elif blue_piece.score > pink_piece.score:
				winner__screen.label.text = "Blue won!"
				winner__screen.texture_rect.texture = load("res://Art/blue piece.png")
			else:
				print("both won")
				winner__screen.label.text = "It is a tie!"
				winner__screen.texture_rect.texture = load("res://Art/both.png")
			return
			
		if pink_piece_turn:
			print("pink piece's turn")
			pink_piece_turn = false
		else:
			print("blue piece's turn")
			pink_piece_turn = true
		
		if game_spaces[piece.place].direction == Direction.WhichWay.BACK:# first check and move back
			var two_spaces_back = piece.place - 2
			while piece.place != two_spaces_back:    
				piece.place -= 1
				move(piece, piece.place)
				timer.start()
				yield(timer, "timeout")  
#				print("MOVE BACK")   
			dice.can_click = true
			turn_label_switcher()
		elif game_spaces[piece.place].direction == Direction.WhichWay.FORWARD:
			var two_spaces_forward = piece.place + 2
			while piece.place != two_spaces_forward:     
				piece.place += 1
#				print("MOVE forward ")      
				move(piece, piece.place)
				timer.start()
				yield(timer, "timeout")    
			dice.can_click = true
			turn_label_switcher()	
		elif game_spaces[piece.place].direction == Direction.WhichWay.QUESTION:		
#			print("this question part is working.")	
#			var question_box = preload("res://Question Boxes/questionbox.tscn")#LOAD IT
			question_boxes.shuffle()		
			var question_box = question_boxes.front() #LOAD IT
			var question = question_box.instance() #INSTANCE IT
			canvas_layer.add_child(question) #ADD IT
			#POSITION IT
			dice.can_click = false
		elif game_spaces[piece.place].direction == Direction.WhichWay.REGULAR:
			dice.can_click = true
			turn_label_switcher()
			
func bounceback(roll):
	var go_back = piece.place - (roll - 1)
	while piece.place != go_back:    
		piece.place -= 1
		move(piece, piece.place)
		timer.start()
		yield(timer, "timeout") 
		
	if pink_piece_turn:
		print("pink piece's turn")
		pink_piece_turn = false
	else:
		print("blue piece's turn")
		pink_piece_turn = true
		
	dice.can_click = true
	turn_label_switcher()	
	print('end bounceback func')
	
		
func move(piece, place):	
	piece_is_moving = true
	
	if piece.place < game_spaces.size():
		var tween = Tween.new() # Create a new Tween node
		add_child(tween)
	#	print("place: ", place)

		# Animate the position of pink_piece from current to target position in 1 second
		tween.interpolate_property(
			piece, "position",          # property to animate
			piece.position,             # start value
			game_spaces[place].position,     # end value
			1,                             # duration in seconds
			Tween.TRANS_LINEAR,              # transition type (linear)
			Tween.EASE_IN_OUT                # easing type (starts/ends slow, middle fast)
		)
		
		tween.start() 	# Start the tween
		tween.connect("tween_completed", self, "_on_tween_done")
		yield(tween, "tween_completed") # Wait until the tween completes
		tween.queue_free() # Remove the tween node to free memory
	#	dice.can_click = true # this leads constant dice roll if pressed.
	piece_is_moving = false

func _on_tween_done(object, key):
	audio_stream_player.play()

func _on_send_piece(sent_piece):
	pink_piece_turn = sent_piece
	if pink_piece_turn: # and signal change require to trigger it
		camera_2d__pink_piece.current = true
		piece = pink_piece
	else:
		camera_2d__blue_piece.current = true
		piece = blue_piece		
	
	print("THe turn is ", piece)
#	dice.can_click = true
	

func _on_question_box_gone(point):
	print("Event bus correctly fired")
	if point == true:
		if !pink_piece_turn: # It seems confusign bec. the turn changes the time question box gone. 
			pink_piece.score = pink_piece.score + 1
			score_label.text = "Pink: " + str(pink_piece.score) + "\nBlue: " + str(blue_piece.score)
		else:
			blue_piece.score = blue_piece.score + 1
			score_label.text = "Pink: " + str(pink_piece.score) + "\nBlue: " + str(blue_piece.score)
		
#		print(score)
#		score_label.text = str(score)
	yield(get_tree(), "idle_frame")
	dice.can_click = true
	turn_label_switcher()
	
func turn_label_switcher():
	while piece_is_moving:
		yield(get_tree(), "idle_frame")
		
	turn_label.visible = true 
	
	if pink_piece_turn:
		turn_label.label.text = "Pink's turn"
		transition_camera.transition_camera2D(camera_2d__blue_piece, camera_2d__pink_piece, blue_piece)
	else:
		turn_label.label.text = "Blue's turn"
		transition_camera.transition_camera2D(camera_2d__pink_piece, camera_2d__blue_piece, pink_piece)
		
	turn_label.timer.start()
	
