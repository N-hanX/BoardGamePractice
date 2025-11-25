extends Node2D

onready var pink_piece : Sprite = $PinkPiece
onready var blue_piece : Sprite = $BluePiece
export(Array, NodePath) var game_spaces_paths
#export var question_boxes : Array[PackedScene]
export(Array, PackedScene) var question_boxes
var game_spaces : Array = [Spot]
var place : int = 1
onready var dice  := $Dice
onready var timer := $Timer
onready var canvas_layer: CanvasLayer = $CanvasLayer
var score : int = 0
onready var score_label: Label = $CanvasLayer/Score
var pink_piece_turn : bool = true
onready var turn_label: PanelContainer = $CanvasLayer/TurnLabel
onready var winner__screen: CenterContainer = $"CanvasLayer/Winner Screen"
onready var piece

func _ready():
	for path in game_spaces_paths:
		var node = get_node(path)
		if node and node is Position2D:
			game_spaces.append(node)
			

#	print("Game spaces size:", game_spaces[game_spaces.size() - 1])
	Events.connect("question_box_gone", self, "_on_question_box_gone")
#	piece = pink_piece # just initilization
	Events.connect("send_piece", self,"_on_send_piece")
	
func _input(event: InputEvent) -> void: # now signaling changed from dice 
	if pink_piece_turn: # and signal change require to trigger it
		piece = pink_piece
	else:
		piece = blue_piece		
		
	if event.is_action_pressed("ui_click") and dice.can_click == true:
		print("Am I Here")
		if piece.i_won == false:
			dice.roll()
		else:
			pink_piece_turn = !pink_piece_turn
			turn_label_switcher()

func _on_dice_dice_has_rolled(roll) -> void:
#	print(roll)
	roll = 6 # for testing
	
#	if piece == pink_piece: roll = 20 # specific case test fix:  dice still rolling illogically
	
	if blue_piece.place  >= game_spaces.size() - 1 and pink_piece.place >= game_spaces.size() - 1:
		# if both of these pieces are at the winner's circle
		winner__screen.visible = true	
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
				piece.place = game_spaces.size()
				piece.i_won = true
				dice.can_click = true
				pink_piece_turn = !pink_piece_turn
				turn_label_switcher()
				return
			
	if roll == 0: # signs of stop the move
		if piece.place >= game_spaces.size():	
			dice.can_click = true
			turn_label_switcher()
			return
		
		dice.can_click = true
		move(piece, piece.place)
		timer.start()                      
		yield(timer, "timeout")     
#		print("MOVE REGULAR for roll = 0 ")    
		if blue_piece.place >= game_spaces.size() - 1 and pink_piece.place >= game_spaces.size() - 1:
			# if both of these pieces are at the winner's circle
			winner__screen.visible = true	
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
			
			turn_label_switcher()

		elif game_spaces[piece.place].direction == Direction.WhichWay.FORWARD:
			var two_spaces_forward = piece.place + 2
			while piece.place != two_spaces_forward:     
				piece.place += 1
#				print("MOVE forward ")      
				move(piece, piece.place)
				timer.start()
				yield(timer, "timeout")    
			
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
			turn_label_switcher()
		
func move(piece, place):	
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
		yield(tween, "tween_completed") # Wait until the tween completes
		tween.queue_free() # Remove the tween node to free memory
	#	dice.can_click = true # this leads constant dice roll if pressed.

func _on_send_piece(sent_piece):
	pink_piece_turn = sent_piece
	if pink_piece_turn: # and signal change require to trigger it
		piece = pink_piece
	else:
		piece = blue_piece		
	
	print("THe turn is ", piece)
	dice.can_click = true
	

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
	turn_label.visible = true 
	
	if pink_piece_turn:
		turn_label.label.text = "Pink's turn"
	else:
		turn_label.label.text = "Blue's turn"
		
	
	turn_label.timer.start()
	
