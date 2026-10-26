#----------------------------------------------------------------------------
#Game : PLAYER (P), WALLS, REWARD (R)
#Memory Mapped I/O Addresses
#----------------------------------------------------------------------------

#MMIO hardware address
.eqv controls_keyboard 	0xffff0000 #Keyboard status (bit 0 = ready)
.eqv data_keyboard 	0xffff0004 #The actual ASCII key pressed
.eqv controls_display  	0xffff0008 #Display status (bit 0 = ready)
.eqv data_display      	0xffff000c #The ASCII character to display

.data
score:    	.word 0 #integer to track current score
player_a: 	.word 5 #starting A position of 'P'
player_b: 	.word 5 #starting B position
reward_a: 	.word 2 #reward a position
reward_b: 	.word 2 #reward b position
enemy_a:	.word 1 #enemy_a position
enemy_b:	.word 1 #enemy b position

label_scores:      	.asciiz "Score: "
message_game_over: 	.asciiz "Game Over\nFinal Score: "
char_wall:         	.asciiz "#"
char_player:       	.asciiz "P"
char_reward:       	.asciiz "R"
char_enemy:		.asciiz "E"
char_space:        	.asciiz " "
newline:           	.asciiz "\n"

.text
.globl main

main:
	#initializing
	li $v0, 41 #syscall 41: Set PRNG seed
	li, $a0, 0 #using generator 0
	syscall #initialize the random number generator
	
	jal reward_spawn #call function to postion first reward random

#the main game loop
loop_game:
	#Step 1: Render the game
	jal frame_render
	
	#Step2: Checking win Condition
	lw $t0, score #Loading current score in $t0
	li $t1, 100 #Load 100 to $t1
	bge $t0, $t1, game_end # Jump to game end if score greater or equal to 100
	
	#Step3: Input Handling (Polling)
keyboard_poll:
	lw $t0, controls_keyboard #reading keyboard (status) register
	andi $t0, $t0, 1 #preserve only last bit (ready bit)
	beq $t0, $zero, keyboard_poll #bit 0 no key pressed; system waits for input
	
	lw $t1, data_keyboard #load ASCII key value in $t1,when  keyboard is ready
	
	lw $s0, player_a 
	lw $s1, player_b
	
	#key match for 'w', 'a', 's' or 'd'
	li $t2, 119 #ASCII of 'w'
	beq $t1, $t2, move_up    # if 'w',  go up
	li $t2, 97  #ASCII of 'a
	beq $t1, $t2, move_left  # if 'a',  go up
	li $t2, 115 #ASCII of 's'
	beq $t1, $t2, move_down  # if 's',  go up
	li $t2, 100 #ASCII of 'd'
	beq $t1, $t2, move_right # if 'd',  go up
	
	j keyboard_poll #if another key is pressed, ignore and await it
	
move_up:    	addi $s1, $s1, -1 # move_up: B =  B - 1 
	    	j collision_check
move_down:  	addi $s1, $s1, 1  # move_down: B =  B + 1
	    	j collision_check
move_left:  	addi $s0, $s0, -1 # move_left: A =  A - 1
	    	j collision_check
move_right: 	addi $s0, $s0, 1  # move_right: A =  A + 1

collision_check:
	# wall collision detection
	#If the player collides with index 0 or 9, game terminates. walls are 0 and 9
	ble $s0, 0, game_end # collide with left wall
	bge $s0, 9, game_end # collide with right wall
	ble $s1, 0, game_end # collide with top wall
	bge $s1, 9, game_end # collide with bottom wall
	
	lw $t2, enemy_a #load enemy a 
	lw $t3, enemy_b #load enemy b
	bne $s0, $t2, position_save #if a is different, player lives
	beq $s1, $t3, game_end #if a and b is same, player is dead
	
position_save:
	#Collision check successful, update the coordinates to RAM
	sw $s0, player_a
	sw $s1, player_b
	
	#check for  collection reward
	lw $t0, reward_a #load current reward_a
	lw $t1, reward_b #load current reward_b
	bne $s0, $t0, turn_enemy #if player_a != reward_a, reward was not obtained
	bne $s1, $t1, turn_enemy #if player_b != reward_b, reward was not obtained
	
	#Player reach the reward, updating the score
	lw $t0, score #Getting current score
	addi $t0, $t0, 5 #5 points added
	sw $t0, score #save the  update score to RAM
	jal reward_spawn #generate new reward at random position

# enemy movement
turn_enemy:
	lw $t2, enemy_a
	lw $t3, enemy_b
	lw $t0, player_a
	lw $t1, player_b
	
	#chase player horzontally
	beq $t2, $t0, check_enemy_y
	blt $t2, $t0, enemy_in_x #if enemy is left of player, move right
	addi $t2, $t2, -1 #else moves left
	j enemy_in_y

enemy_in_x:
	addi $t2, $t2, 1
	
check_enemy_y:
	#chasing player vertically
	beq $t3, $t1, enemy_save
	blt $t3, $t1, enemy_in_y #if enemy is above player, move down
	addi $t3, $t3, -1 #else move up
	j enemy_save
enemy_in_y:
	addi $t3, $t3, 1
	
enemy_save:
	sw $t2, enemy_a
	sw $t3, enemy_b
	
	#final check
	bne $t2, $s0, logic_done
	beq $t3, $s1, game_end
	
logic_done:
	j loop_game #move completed, return to start to redraw the screen
	
#Rendering graphics (drawing 10x10grid)

frame_render:
	move $s7, $ra #Save "Return Address" for later use
	
	#Print the score
	la $a0, label_scores #loading address of "Score: "
	jal strings_print #Print string
	lw $a0, score #load score value
	jal int_print 
	la $a0, newline #load address of newline
	jal strings_print # print
	
	#starting nested loop (rows and columns)
	li $t7, 0 #row counter = $t7
loop_row:
	li $t6, 0 #column counter = $t6
loop_column:
	#step 1: check wall
	beq $t7, 0, is_wall 
	beq $t7, 9, is_wall
	beq $t6, 0, is_wall
	beq $t6, 9, is_wall
	
	#step 2: check player
	lw $t0, player_a 
	lw $t1, player_b
	bne $t6, $t0, enemy_check 
	bne $t7, $t1, enemy_check
	la $a0, char_player
	j cell_prints
	
enemy_check:
	#step 3 : check enemy
	lw $t0, enemy_a
	lw $t1, enemy_b
	bne $t6, $t0, reward_check
	bne $t7,$t1, reward_check
	la $a0, char_enemy
	j cell_prints
	
reward_check:
	#step 4: check reward
	lw $t0, reward_a
	lw $t1, reward_b
	bne $t6, $t0, space_draw
	bne $t7, $t1, space_draw
	la $a0, char_reward
	j cell_prints
	
space_draw:
	la $a0, char_space #load " "
	j cell_prints
	
is_wall:
	la $a0, char_wall #load "#"

cell_prints:
	jal strings_print #send the selected character to display
	addi $t6, $t6,  1 #move to next column
	blt $t6, 10, loop_column #if it is less than 10, repeat innner loop
	
	la $a0, newline #complete row, print newline
	jal strings_print
	addi $t7, $t7, 1 #move to next row
	blt $t7, 10, loop_row
	
	move $ra, $s7 #Restore Return Address
	jr $ra #Returning to main game loop

#Helper function: MMIO & Randomization

#spawn reward: generate random between 1 and 8
reward_spawn:
	li $v0, 42 #syscall 42: random number in range
	li $a1, 8 #range 0-7
	syscall
	addi $a0, $a0, 1 # move to range 1-8
	sw $a0, reward_a #save reward a
	
	li $v0, 42
	li $a1, 8
	syscall
	addi $a0, $a0, 1
	sw $a0, reward_b #save reward b
	jr $ra
	
#Helper: Print string through MMIO
strings_print:
	move $t8, $a0
sp_loop:	#strings print loop
	lb $t9, ($t8)		#load current byte
	beqz $t9, sp_end	#exit if Null
transmitter_wait:
	lw $t0, controls_display #checks display hardware status
	andi $t0, $t0, 1 #is "Ready" bit 1?
	beq $t0, $zero, transmitter_wait #if 0, hardware is busy, loop and wait
	sw $t9, data_display #hardware is ready, write character to the screen
	addi $t8, $t8, 1 #proceed to next letter
	j sp_loop
sp_end:
	jr $ra #return

int_print:
	#convert number (0-999) in two  ASCII letter for printing
	move $s5, $ra #saves the return address
	
	#it gets hundred
	li $t0, 100 
	div $a0, $t0 #divide score by 100
	mflo $t1 # t1 = hundred digit
	mfhi $t2 # t2 = remainder
	
	#2. it gets the tens and units
	li $t0, 10
	div $t2, $t0 #divide score by 10
	mflo $t3 # t3 = ten digit
	mfhi $t4 # t4 = units digit
	
	#3 convert number ASCII and Print
	addi $a0, $t1, 48
	jal char_direct_print
	
	addi $a0, $t3, 48 #converts first digit into character;adds 48  to convert  number to ASCII character
	jal char_direct_print #prints tens
	
	addi $a0, $t4, 48 # converts second digit to character; adds 48  to convert  number to ASCII character
	jal char_direct_print #print units
	
	move $ra, $s5 #restores return address
	jr $ra

char_direct_print:
	#faster function to print only one character
	lw $t0, controls_display
	andi $t0, $t0, 1
	beq $t0, $zero, char_direct_print #waits until scrren is ready
	sw $a0, data_display #send character
	jr $ra

#Game ends	
game_end:
	#clear screen by printing several newlines
	li $t3, 0
cls:
	la $a0, newline
	jal strings_print
	addi $t3, $t3, 1
	blt $t3, 25, cls #prints 25 empty lines
	
	#Displaying final outputs
	la $a0, message_game_over #prints game over
	jal strings_print 
	lw $a0, score #loads final score
	jal int_print #prints final score 
	
	li $v0, 10 #syscall 10: exit
	syscall
