extends "res://Main.gd"

var old_roll : int
export(PackedScene) var direction_picker

func _ready():
	._ready()
	Events.connect("picked_direction", self, "_on_picked_direction")
	
func _on_picked_direction(direction):
	match direction:
		Direction.UserPickedDirection.UP:
			piece.place = 6
		Direction.UserPickedDirection.DOWN:
			piece.place = 11
			
	print("old_roll", old_roll)
	move_the_piece_and_find_the_place(old_roll)
	
func _on_dice_dice_has_rolled(roll) -> void:
	roll = 6
	move_the_piece_and_find_the_place(roll)
	
func move_the_piece_and_find_the_place(roll):
#	print(roll)
#	roll = 6 # for testing
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
			
			if game_spaces[piece.place].direction == Direction.WhichWay.CROSSROAD:
				print("CROSS ROAD")
				old_roll = roll
				roll = 0

				#INSTANCE IT
				var direction_box = direction_picker.instance()
				#ADD IT
				canvas_layer.add_child(direction_box)
				dice.can_click = false
				move(piece, piece.place)
				timer.start()                      
				yield(timer, "timeout")  
				
				# NOTE: This approach seems confusing and might lead bug.
				piece.place += 1
				old_roll = old_roll - 1
				return
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
