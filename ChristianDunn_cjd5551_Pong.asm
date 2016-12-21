# Author   : Christian Dunn
# Date     : November 27th, 2016
# Purpose  : Using the Bitmap display create a pong game that allows the user to
#            run a cpu vs cpu simulated match or a cpu vs player match. The keyboard 
#	     interface will be used to omplement direction keys for the user to 
#	     move their goalie according to where the pong is directed.
# Compiler : MARS 4.4

#####################################################################################
#			Bitmap Display Options					    #
# Unit width     : 1					      #######################
# Unit height    : 1					      #		NOTE!       #
# Display width  : 512					      # Uses Keyboard Simul.#
# Display height : 256					      #######################
# Base address   : heap								    #
#####################################################################################

.data
Menu_Selc         : .asciiz "PRE55 0 [CPU V CPU] OR 1 [CPUVP] TO PLAY"
Game_Win          : .asciiz "Congratulations! You win!"
Game_Again        : .asciiz "Play again? Press y or n"
Score_Prompt      : .asciiz "5CORE: "
SPACE_PROMPT      : .asciiz " "
Zero_Prompt       : .asciiz "0"
One_Prompt        : .asciiz "1"
Two_Prompt        : .asciiz "2"
Three_Prompt      : .asciiz "3"
Four_Prompt       : .asciiz "4"
Five_Prompt       : .asciiz "5"
Six_Prompt        : .asciiz "6"
Seven_Prompt      : .asciiz "7"
Eight_Prompt      : .asciiz "8"
Nine_Prompt       : .asciiz "9"

StackBeg   : .word 0:80
StackEnd   : 

num_player      : .word 0
Player_score    : .word 0
CPU_score       : .word 0
CPU_Direction   : .word 0
P1_Direction    : .word 0
CPU_Position    : .word 0
P1_Position     : .word 0
horz_velocity   : .word 8
vert_velocity   : .word -8
vert_direction  : .word -8
CPU_velocity    : .word 0
CPU_counter     : .word 0
CPU_Difficulty  : .word 12
Hit_Distance    : .word 0
Ball_xpos       : .word 0
Ball_ypos       : .word 0
Player_Input    : .word 0
Last_Direction  : .word 0
hex             : .word 0x10040000

ColorTable :
	.word 0x000000
	.word 0x0000ff
	.word 0x00ff00
	.word 0xff0000
	.word 0x00ffff
	.word 0xff00ff
	.word 0xffa500
	.word 0xffff00
	.word 0xffffff
Colors: 
	.word 0x000000        
        .word 0xffffff 
DigitTable:
	.byte   ' ', 0,0,0,0,0,0,0,0,0,0,0,0
        .byte   '0', 0x7e,0xff,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '1', 0x38,0x78,0xf8,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18
        .byte   '2', 0x7e,0xff,0x83,0x06,0x0c,0x18,0x30,0x60,0xc0,0xc1,0xff,0x7e
        .byte   '3', 0x7e,0xff,0x83,0x03,0x03,0x1e,0x1e,0x03,0x03,0x83,0xff,0x7e
        .byte   '4', 0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7f,0x03,0x03,0x03,0x03,0x03
        .byte   '5', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0x7f,0x03,0x03,0x83,0xff,0x7f
        .byte   '6', 0xc0,0xc0,0xc0,0xc0,0xc0,0xfe,0xfe,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '7', 0x7e,0xff,0x03,0x06,0x06,0x0c,0x0c,0x18,0x18,0x30,0x30,0x60
        .byte   '8', 0x7e,0xff,0xc3,0xc3,0xc3,0x7e,0x7e,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '9', 0x7e,0xff,0xc3,0xc3,0xc3,0x7f,0x7f,0x03,0x03,0x03,0x03,0x03
        .byte   '+', 0x00,0x00,0x00,0x18,0x18,0x7e,0x7e,0x18,0x18,0x00,0x00,0x00
        .byte   '-', 0x00,0x00,0x00,0x00,0x00,0x7e,0x7e,0x00,0x00,0x00,0x00,0x00
        .byte   '!', 0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x00,0x00,0x18,0x18
        .byte   '[', 0xf0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xf0
        .byte   ']', 0x0f,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x0f
        .byte   '*', 0x00,0x00,0x00,0x66,0x3c,0x18,0x18,0x3c,0x66,0x00,0x00,0x00
        .byte   '/', 0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff
        .byte   '=', 0x00,0x00,0x00,0x00,0x7e,0x00,0x7e,0x00,0x00,0x00,0x00,0x00
        .byte   'A', 0x18,0x3c,0x66,0xc3,0xc3,0xc3,0xff,0xff,0xc3,0xc3,0xc3,0xc3
        .byte   'B', 0xfc,0xfe,0xc3,0xc3,0xc3,0xfe,0xfe,0xc3,0xc3,0xc3,0xfe,0xfc
        .byte   'C', 0x7e,0xff,0xc1,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc1,0xff,0x7e
        .byte   'D', 0xfc,0xfe,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xfe,0xfc
        .byte   'E', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0xfe,0xc0,0xc0,0xc0,0xff,0xff
        .byte   'F', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0xfe,0xc0,0xc0,0xc0,0xc0,0xc0
        .byte   'G', 0xff,0xc3,0xc3,0xc0,0xc0,0xc0,0xc0,0xcf,0xc3,0xc3,0xc3,0xff
        .byte   'H', 0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0xc3,0xc3,0xc3,0xc3,0xc3
        .byte   'I', 0xff,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0xff
        .byte   'J', 0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0xe3,0xc3,0xc3,0xff
        .byte   'K', 0xc0,0xc3,0xc3,0xc6,0xcc,0xd8,0xf0,0xd8,0xcc,0xc6,0xc3,0xc3
        .byte   'L', 0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xff
        .byte   'M', 0xc3,0xc3,0xc3,0xe7,0xdb,0xdb,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3
        .byte   'N', 0x00,0x00,0xc3,0xe3,0xe3,0xd3,0xd3,0xcb,0xcb,0xc7,0xc7,0xc3
        .byte   'O', 0xff,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xff
        .byte   'P', 0xff,0xc3,0xc3,0xc3,0xc3,0xff,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0
        .byte   'R', 0xff,0xc3,0xc3,0xc3,0xc3,0xff,0xf0,0xd8,0xcc,0xc6,0xc3,0xc3
        .byte   'T', 0xff,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18
        .byte   'U', 0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xff
        .byte   'W', 0x00,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xdb,0xdb,0xe7,0x66
        .byte   'X', 0xc3,0xc3,0x66,0x66,0x3c,0x18,0x18,0x3c,0x66,0x66,0xc3,0xc3
        .byte   'Y', 0xc3,0xc3,0xc3,0x66,0x66,0x66,0x3c,0x18,0x18,0x18,0x18,0x18
        .byte   'Z', 0xff,0x03,0x06,0x06,0x0c,0x0c,0x18,0x18,0x30,0x30,0x60,0xff
        .byte   'V', 0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0x66,0x66,0x3c,0x18
        .byte   '!', 0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x00,0x00,0x18,0x18
        .byte   '.', 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x18,0x18
        .byte   ':', 0x00,0x00,0x00,0x18,0x18,0x00,0x00,0x18,0x18,0x00,0x00,0x00

.text
main:
	la $sp, StackEnd
	
	jal Title_Screen
	
	la  $a0, num_player
	jal GetChar
	
	lw  $a0, num_player
	beq $a0, '0', exit
	beq $a0, '1', CPUvP
	
	CPUvP:
		jal Clear_Title_Screen
		jal DrawBoard
		jal NewGame
		
		b   exit
		
	exit: 
		jal Clear_Title_Screen
		li  $v0, 10
		syscall
	
# Procedure : GetChar
# Purpose   : Get character value from keyboard simulator and store in register
# Inputs    : $a0 -> Memory location to store player info
# Outputs   : $v0 -> Returns character value in $v0 if entered 
GetChar:
	subi $sp, $sp, 4
	sw   $ra, 0($sp)
	li   $t2, 0
	j check
	cloop:
		addi $t2, $t2, 1
		beq  $t2, 1000000, endProgram
	check:
		jal  IsCharThere
		beq  $v0, $0, cloop
		lui  $t0, 0xffff
		lw   $v0, 4($t0)
		sw   $v0, 0($a0)
		lw   $ra, 0($sp)
		addi $sp, $sp, 4
		jr   $ra
	endProgram:
		li   $v0, 10
		syscall
		
# Procedure : GetChar
# Purpose   : Get character value from keyboard simulator and store in register
# Inputs    : $a0 -> Memory location to store player info
# Outputs   : $v0 -> Returns character value in $v0 if entered 
GetChar2:
	subi $sp, $sp, 4
	sw   $ra, 0($sp)
	li   $t2, 0
	j check2
	cloop2:
		addi $t2, $t2, 1
		beq  $t2, 3500, return2
	check2:
		jal  IsCharThere
		beq  $v0, $0, cloop2
		lui  $t0, 0xffff
		lw   $v0, 4($t0)
		sw   $v0, Player_Input
	return2:
		lw   $ra, 0($sp)
		addi $sp, $sp, 4
		jr   $ra

# Procedure : IsCharThere
# Purpose   : To check and see if character has been entered within keyboard simulator
# Outputs   : $v0 -> returns either 1 or 0 depending on if value has been entered 
IsCharThere:
	lui $t0, 0xffff
	lw  $t1, 0($t0)
	and $v0, $t1, 1
	jr  $ra
	
# Procedure : CalcAddr
# Purpose   : To calculate address based upon given x and y coordinates
# Inputs    : $a0 -> x coordinate (0-31)
#	      $a1 -> y coordinate (0-31)
# Outputs   : $v0 -> memory address
CalcAddress:
	lw      $t0, hex
	sll     $t1, $a0, 2     # assumes mars was configured as 256 x 256
        addu    $t0, $t0, $t1   # and 1 pixel width, 1 pixel height
        sll     $t1, $a1, 11    # (a0 * 4) + (a1 * 4 * 512)
        addu    $v0, $t0, $t1   # t9 = memory address for this pixel
	jr  $ra

# Procedure : GetColor
# Purpose   : Returns color used to write to display
# Inputs    : $a2 -> color number (0-7)
# Outputs   : $v1 -> actual number to write to the display
GetColor:
	la   $t0, ColorTable
	sll  $a2, $a2, 2
	add  $a2, $a2, $t0
	lw   $v1, 0($a2)
	jr   $ra
	
# Procedure : DrawDot
# Purpose   : To draw dot on bitmap display given x and y coordinates
# Inputs    : $a0 -> x coordinate (0-31)
#	      $a1 -> y coordinate (0-31)
#	      $a2 -> color number (0-7)
DrawDot:
	addiu $sp, $sp, -12
	sw    $ra, 4($sp)
	sw    $a2, 0($sp)
	jal   CalcAddress
	lw    $a2, 0($sp)
	sw    $v0, 0($sp)
	jal   GetColor
	lw    $v0, 0($sp)
	sw    $v1, 0($v0)
	lw    $ra, 4($sp)
	addiu $sp, $sp, 12
	jr    $ra
	
# Procedure : Color_Bar
# Purpose   : To draw a bar with height 18, and length 400
# Inputs    : $a0 -> x coordinate
#             $a1 -> y coordinate
#             $a2 -> color number
#             $a3 -> length of the line
#	      $s0 -> height of line
Color_Bar: 
	
	subi $sp, $sp, 24
	sw   $ra, 0($sp)
	sw   $a0, 4($sp)
	sw   $a2, 12($sp)
	li   $s1, 0

	Bar_Loop:
		sw   $a1, 8($sp)
		sw   $a3, 16($sp)
		sw   $s0, 20($sp)
		jal  HorzLine
		lw   $a0, 4($sp)
		lw   $a1, 8($sp)
		lw   $a2, 12($sp)
		lw   $a3, 16($sp)
		lw   $s0, 20($sp)
		addi $a1, $a1, 1
		addi $s1, $s1, 1
		blt  $s1, $s0, Bar_Loop
		lw   $ra, 0($sp)
		addi $sp, $sp, 24
		jr   $ra
		
# Procedure : Color_Diagonal_Bar
# Purpose   : To draw a bar with height 18, and length 400
# Inputs    : $a0 -> x coordinate
#             $a1 -> y coordinate
#             $a2 -> color number
#             $a3 -> length of the line
#	      $s0 -> height of line
Color_Diagonal_Bar: 
	subi $sp, $sp, 24
	sw   $ra, 0($sp)
	sw   $a2, 12($sp)
	
	Color_Diagonal_Loop:
		sw $a0, 4($sp)
		sw $a1, 8($sp)
		sw $a3, 16($sp)
		jal LtoRLine
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		lw $a3, 16($sp)
		addi $a0, $a0, 1
		subi $s0, $s0, 1
		bnez $s0, Color_Diagonal_Loop
		lw   $ra, 0($sp)
		addi $sp, $sp, 24
		jr   $ra
		
# Procedure : LtoRLine
# Purpose   : To draw digonal line going from left corner to right corner
# Inputs    : $a0 -> x coordinate (0-31)
#	      $a1 -> y coordinate (0-31)
#	      $a2 -> color number (0-7)
#	      $a3 -> length of the line (1-32)
LtoRLine:
	sub $sp, $sp, 24
	sw  $a2, 8($sp)
	sw  $ra, 12($sp)
	
	LtoRLoop:
		sw   $a1, 4($sp)
		sw   $a0, 0($sp)
		jal  DrawDot
		lw   $a0, 0($sp)
		lw   $a1, 4($sp)
		lw   $a2, 8($sp)
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		subi $a3, $a3, 1
		bnez $a3, LtoRLoop
		lw   $ra, 12($sp)
		addi $sp, $sp, 24
		jr   $ra
	
# Procedure : HorzLine
# Purpose   : To draw horizontal line on bitmap display
# Inputs    : $a0 -> x coordinate (0-31)
#	      $a1 -> y coordinate (0-31)
#	      $a2 -> color number (0-7)
#	      $a3 -> length of the line (1-32)
HorzLine:
	sub $sp, $sp, 24
	sw  $a1, 4($sp)
	sw  $a2, 8($sp)
	sw  $ra, 12($sp)
	
	HorzLoop:
		sw   $a0, 0($sp)
		jal  DrawDot
		lw   $a0, 0($sp)
		lw   $a1, 4($sp)
		lw   $a2, 8($sp)
		addi $a0, $a0, 1
		subi $a3, $a3, 1
		bnez $a3, HorzLoop
		lw   $ra, 12($sp)
		addi $sp, $sp, 24
		jr   $ra
		
# Procedure : VertLine
# Purpose   : To draw vertical line on bitmap display
# Inputs    : $a0 -> x coordinate (0-31)
#	      $a1 -> y coordinate (0-31)
#	      $a2 -> color number (0-7)
#	      $a3 -> length of the line (1-32)
VertLine:
	sub $sp, $sp, 24
	sw  $a0, 4($sp)
	sw  $a2, 8($sp)
	sw  $ra, 12($sp)
	
	VertLoop:
		sw   $a1, 0($sp)
		jal  DrawDot
		lw   $a1, 0($sp)
		lw   $a0, 4($sp)
		lw   $a2, 8($sp)
		addi $a1, $a1, 1
		subi $a3, $a3, 1
		bnez $a3, VertLoop
		lw   $ra, 12($sp)
		addi $sp, $sp, 24
		jr   $ra
		
# OutText: display ascii characters on the bit mapped display
# $a0 = horizontal pixel co-ordinate (0-255)
# $a1 = vertical pixel co-ordinate (0-255)
# $a2 = pointer to asciiz text (to be displayed)
OutText:
        addiu   $sp, $sp, -24
        sw      $ra, 20($sp)

        li      $t8, 1          # line number in the digit array (1-12)
_text1:
        la      $t9, 0x10040000 # get the memory start address
        sll     $t0, $a0, 2     # assumes mars was configured as 256 x 256
        addu    $t9, $t9, $t0   # and 1 pixel width, 1 pixel height
        sll     $t0, $a1, 11    # (a0 * 4) + (a1 * 4 * 512)
        addu    $t9, $t9, $t0   # t9 = memory address for this pixel

        move    $t2, $a2        # t2 = pointer to the text string
_text2:
        lb      $t0, 0($t2)     # character to be displayed
        addiu   $t2, $t2, 1     # last character is a null
        beq     $t0, $zero, _text9

        la      $t3, DigitTable # find the character in the table
_text3:
        lb      $t4, 0($t3)     # get an entry from the table
        beq     $t4, $t0, _text4
        beq     $t4, $zero, _text4
        addiu   $t3, $t3, 13    # go to the next entry in the table
        j       _text3
_text4:
        addu    $t3, $t3, $t8   # t8 is the line number
        lb      $t4, 0($t3)     # bit map to be displayed

        sw      $zero, 0($t9)   # first pixel is black
        addiu   $t9, $t9, 4

        li      $t5, 8          # 8 bits to go out
_text5:
        la      $t7, Colors
        lw      $t7, 0($t7)     # assume black
        andi    $t6, $t4, 0x80  # mask out the bit (0=black, 1=white)
        beq     $t6, $zero, _text6
        la      $t7, Colors     # else it is white
        lw      $t7, 4($t7)
_text6:
        sw      $t7, 0($t9)     # write the pixel color
        addiu   $t9, $t9, 4     # go to the next memory position
        sll     $t4, $t4, 1     # and line number
        addiu   $t5, $t5, -1    # and decrement down (8,7,...0)
        bne     $t5, $zero, _text5

        sw      $zero, 0($t9)   # last pixel is black
        addiu   $t9, $t9, 4
        j       _text2          # go get another character

_text9:
        addiu   $a1, $a1, 1     # advance to the next line
        addiu   $t8, $t8, 1     # increment the digit array offset (1-12)
        bne     $t8, 13, _text1

        lw      $ra, 20($sp)
        addiu   $sp, $sp, 24
        jr      $ra

# Procedure : NewGame
# Purpose   : To start a new game at intial values
# Inputs    : $s0 -> player one's current direction
#	      $s1 -> player two's current direction
#             $s2 -> x-direction of the ball's current movement
#             $s3 -> vert-velocity of the ball's current movement
#             $s4 -> player one's paddle position
#             $s5 -> player two's paddle position
#             $s6 -> x-position of the ball
#             $s7 -> y-position of the ball
NewGame:
	subi $sp, $sp, 4
	sw   $ra, 0($sp)
	
	li   $t0,   8
	sw   $t0,   vert_velocity
	sw   $t0,   horz_velocity
	li   $t0,   -8
	sw   $t0,   vert_direction
	sw   $t0,   vert_velocity
	sw   $zero, CPU_velocity
	sw   $zero, CPU_counter
	li   $t0,   0
	sw   $t0,   CPU_Direction
	sw   $t0,   P1_Direction
	li   $t0,   108
	sw   $t0,   CPU_Position
	sw   $t0,   P1_Position
	sw   $t0,   Ball_ypos
	li   $t0,   256
	sw   $t0,   Ball_xpos
	li   $t0,   0
	
	jal Clear_Field
	
	li $a0, 25
	li $a1, 42
	lw $a2, CPU_score
	jal DrawScore
	li $a0, 462
	li $a1, 42
	lw $a2, Player_score
	jal DrawScore
	
	li  $a0, 91
	lw  $a1, CPU_Position
	li  $a2, 8 
	jal DrawGoalie 
	li  $a0, 408
	lw  $a1, P1_Position
	li  $a2, 8
	jal DrawGoalie
	
	Generate_Animations:
		lw   $ra, 0($sp)
		jal  Hit_Check
		jal  Move_Ball
		
		li   $a0, 408
		lw   $a1, P1_Position
		li   $a2, 8
		lw   $a3, P1_Direction
		jal  DrawGoalie
		sw   $a1, P1_Position
		sw   $a3, P1_Direction
		
		li   $a0, 91
		lw   $a1, CPU_Position
		li   $a2, 8
		CPU_Operation:
			lw   $t0, CPU_counter
			addi $t0, $t0, -8
			sw   $t0, CPU_counter
			bgt  $t0, 0, End_Computer_Operation
			lw   $t0, CPU_velocity
			sw   $t0, CPU_counter
			lw   $t0, CPU_Position
			addi $t1, $t0, 20
			lw   $t0, Ball_ypos
			blt  $t1, $t0, goDown
			li   $t1, 0x01000000
			sw   $t1, CPU_Direction
			j    End_Computer_Operation
		goDown:
			li   $t0, 0x02000000
			sw   $t0, CPU_Direction
		End_Computer_Operation:
			lw   $a3, CPU_Direction
			jal  DrawGoalie
			sw   $a1, CPU_Position
			sw   $a3, CPU_Direction
	Pause_Input:
		jal  GetChar2
		jal  Direction_Change
		j    Generate_Animations
	
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr   $ra
	
# Procedure : Direction_Change
# Purpose   : To change the direction of the components appropriately
Direction_Change:
	lw $a0, Player_Input
	Player1_Up:
		bne $a0, 'w', Player1_Down
		li  $t0, 0x01000000
		sw  $t0, P1_Direction
		j   Direction_Change_Done
	Player1_Down:
		bne $a0, 's', Direction_Change_Done
		li  $t0, 0x02000000
		sw  $t0, P1_Direction
	Direction_Change_Done:
		jr  $ra
        
# Procedure : Hit_Check
# Purpose   : Check to see if a user scored, or hit the ball
Hit_Check:
	subi $sp, $sp, 4
	sw   $ra, 0($sp)
	lw  $t0, Ball_xpos
	lw  $t1, Ball_ypos
	blt $t0, 97,  CPU_loss
	bgt $t0, 415, Player_loss
	ble $t0, 105, Possible_Left_Collision
	b   No_Left_Collision
	Possible_Left_Collision:
		bgt  $t0, 97, Left_Collision
	Left_Collision:
		lw   $t2, CPU_Position
		blt  $t1, $t2, No_Collision
		addi $t3, $t2, 40
		bgt  $t1, $t3, No_Collision
		sub  $t3, $t1, $t2
		sw   $t3, Hit_Distance
		li   $t4, 8
		sw   $t4, horz_velocity
		j    Hit_Occured
	No_Left_Collision:
		bge  $t0, 407, Possible_Right_Collision
		b    No_Collision
		Possible_Right_Collision:
			blt $t0, 415, Right_Collision
			b   No_Collision
	Right_Collision:
		lw   $t2, P1_Position
		blt  $t1, $t2, No_Collision
		addi $t3, $t2, 40
		bgt  $t1, $t3, No_Collision
		sub  $t3, $t1, $t2
		sw   $t3, Hit_Distance
		li   $t4, -8
		sw   $t4, horz_velocity
		j    Hit_Occured
	No_Collision:
		j    Check_Horizontal_Collision
	Hit_Occured:
		li   $a0, 80
		li   $a1, 80
		li   $a2, 32
		li   $a3, 127
		li   $v0, 31
		syscall
		lw   $t0, CPU_Difficulty
		sw   $t0, CPU_velocity
		lw   $t0, Hit_Distance
		bge  $t0, 40, Hit_Bot_Low
		bge  $t0, 32, Hit_Bot_Mid
		bge  $t0, 24, Hit_Bot_Top
		bge  $t0, 16, Hit_Top_Low
		bge  $t0,  8, Hit_Top_Mid
		bge  $t0,  0, Hit_Top_Top
	Hit_Top_Top:
		li   $t0, 8
		sw   $t0, vert_velocity
		li   $t0, -8
		sw   $t0, vert_direction
		j    Check_Horizontal_Collision
	Hit_Top_Mid:
		li   $t0, 16
		sw   $t0, vert_velocity
		li   $t0, -8
		sw   $t0, vert_direction
		j    Check_Horizontal_Collision
	Hit_Top_Low:
		li   $t0, 32
		sw   $t0, vert_velocity
		li   $t0, -8
		sw   $t0, vert_direction
		j    Check_Horizontal_Collision
	Hit_Bot_Top:
		li   $t0, 32
		sw   $t0, vert_velocity
		li   $t0, 8
		sw   $t0, vert_direction
		j    Check_Horizontal_Collision
	Hit_Bot_Mid:
		li   $t0, 16
		sw   $t0, vert_velocity
		li   $t0, 8
		sw   $t0, vert_direction
		j    Check_Horizontal_Collision
	Hit_Bot_Low:
		li   $t0, 8
		sw   $t0, vert_velocity
		li   $t0, 8
		sw   $t0, vert_direction
		j    Check_Horizontal_Collision
	Check_Horizontal_Collision:
		lw   $t1, Ball_ypos
		bge  $t1, 226, Wall_Hit
		ble  $t1,  30, Collision_Check_Finished
	Wall_Hit:
		lw   $t0, vert_velocity
		bgt  $t0, 8, Collision_Check_Finished
		lw   $t0, vert_direction
		xori $t0, $t0, 0xffffffff
		addi $t0, $t0, 1
		sw   $t0, vert_direction
	Collision_Check_Finished:
		lw   $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra 
		
# Procedure : CPU_loss
# Purpose   : To increment players' scores according to which player scored
CPU_loss:
	lw   $t0, Player_score
	addi $t0, $t0, 1
	sw   $t0, Player_score
	li   $t1, 8
	sw   $t1, horz_velocity
	sw   $zero, 0xffff0004
	lw   $t1, Player_score
	beq  $t1, 10, End_Game
	j    Point_Sound
	
# Procedure : Player_loss
# Purpose   : To increment players' scores according to which player scored
Player_loss:
	lw   $t0, CPU_score
	addi $t0, $t0, 1
	sw   $t0, CPU_score
	li   $t1, -8
	sw   $t1, horz_velocity
	sw   $zero, 0xffff0004
	lw   $t1, CPU_score
	beq  $t1, 10, End_Game
	j    Point_Sound
	
# Procedure : Point_Sound
# Purpose   : Play a midi tone whenever a point is scored
Point_Sound:
	li   $a0, 80
	li   $a1, 300
	li   $a2, 121
	li   $a3, 127
	li   $v0, 31
	syscall
	j    NewGame
	
# Procedure : End_Game
# Purpose   : Reset the Game Details
End_Game:
	jal Clear_Field2
	sw  $zero, CPU_score
	sw  $zero, Player_score
	sw  $zero, 0xffff0000
	sw  $zero, 0xffff0004
	j   main
		
# Procedure : Move_Ball
# Purpose   : To draw ball to screen and appropriately animate according to speed/position
Move_Ball:
	subi $sp, $sp, 4
	sw   $ra, 0($sp)
	lw   $a0, Ball_xpos
	lw   $a1, Ball_ypos
	li   $a2, 0
	li   $a3, 8
	li   $s0, 8
	jal  Color_Bar
	
	lw   $t0, horz_velocity
	lw   $t1, Ball_xpos
	add  $t1, $t1, $t0
	sw   $t1, Ball_xpos
	lw   $t0, vert_velocity
	addi $t0, $t0, -8
	sw   $t0, vert_velocity
	lw   $t2, Ball_ypos
	lw   $t3, Last_Direction
	ble  $t2, 38, Vert_Change_Down
	bge  $t2, 226,Vert_Change_Up
	beq  $t3, 8, Vert_Change_Down
	
	Vert_Change_Up:
		lw   $t3, Ball_ypos
		li   $t4, -8
		sw   $t4, Last_Direction
		add  $t3, $t3, $t4
		sw   $t3, Ball_ypos
		j    No_Vert_Change
	Vert_Change_Down:
		lw   $t3, Ball_ypos
		li   $t4, 8
		sw   $t4, Last_Direction
		add  $t3, $t3, $t4
		sw   $t3, Ball_ypos
	No_Vert_Change:
		lw   $a0, Ball_xpos
		lw   $a1, Ball_ypos
		li   $a2, 8
		li   $a3, 8
		li   $s0, 8
		jal  Color_Bar
		lw   $ra, 0($sp)
		addi $sp, $sp, 4
		jr   $ra
        
# Procedure : DrawScore
# Purpose   : As user's score changes, draw the appropriate score
# Inputs    : $a0 -> x-axis component
#	      $a1 -> y-axis component
#             $a2 -> pointer to the location of user scores
DrawScore:
	subi $sp, $sp, 16
	sw   $ra, 0($sp)
	sw   $a0, 4($sp)
	sw   $a1, 8($sp)
	sw   $a2, 12($sp)
	beq  $a2, 0, Zero_Point
	beq  $a2, 1, One_Point
	beq  $a2, 2, Two_Point
	beq  $a2, 3, Three_Point
	beq  $a2, 4, Four_Point
	beq  $a2, 5, Five_Point
	beq  $a2, 6, Six_Point
	beq  $a2, 7, Seven_Point
	beq  $a2, 8, Eight_Point
	beq  $a2, 9, Nine_Point
	
	Zero_Point:
		la  $a2, Zero_Prompt
		jal OutText
		j   Score_Finished
	One_Point:
		la  $a2, One_Prompt
		jal OutText
		j   Score_Finished
	Two_Point:
		la  $a2, Two_Prompt
		jal OutText
		j   Score_Finished
	Three_Point:
		la  $a2, Three_Prompt
		jal OutText
		j   Score_Finished
	Four_Point:
		la  $a2, Four_Prompt
		jal OutText
		j   Score_Finished
	Five_Point:
		la  $a2, Five_Prompt
		jal OutText
		j   Score_Finished
	Six_Point:
		la  $a2, Six_Prompt
		jal OutText
		j   Score_Finished
	Seven_Point:
		la  $a2, Seven_Prompt
		jal OutText
		j   Score_Finished
	Eight_Point:
		la  $a2, Eight_Prompt
		jal OutText
		j   Score_Finished
	Nine_Point:
		la  $a2, Nine_Prompt
		jal OutText
		j   Score_Finished
	Score_Finished:
		lw   $ra, 0($sp)
		lw   $a2, 12($sp)
		addi $sp, $sp, 16
		jr   $ra
	
# Procedure : DrawGoalie
# Purpose   : To draw goalie dependent on user input and previous location
# Inputs    : $a0 -> x-position
#	      $a1 -> y-position
#             $a2 -> color number
#             $a3 -> direction of movement
DrawGoalie:
	subi $sp, $sp, 20
	sw   $ra, 0($sp)
	sw   $a0, 4($sp)
	sw   $a1, 8($sp)
	sw   $a2, 12($sp)
	sw   $a3, 16($sp)
	beq  $a3, 0x02000000, Goalie_Down
	bne  $a3, 0x01000000, Goalie_Stay
	Goalie_Up:
		addi $a1, $a1, 32
		ble  $a1, 62, Goalie_Stay
		li   $a2, 0
		li   $a3, 8
		li   $s0, 8
		jal  Color_Bar
		lw   $ra, 0($sp)
		lw   $a0, 4($sp)
		lw   $a1, 8($sp)
		lw   $a2, 12($sp)
		li   $a3, 8
		li   $s0, 40
		addi $a1, $a1, -8
		ble  $a1, 30, Goalie_Stay
		jal  Color_Bar
		lw   $ra, 0($sp)
		lw   $a1, 8($sp)
		addi $a1, $a1, -8
		sw   $a1, 8($sp)
		j    Goalie_Stay
	Goalie_Down:
		bge  $a1, 190, Goalie_Stay
		li   $a2, 0
		li   $a3, 8
		li   $s0, 8
		jal  Color_Bar
		lw   $ra, 0($sp)
		lw   $a0, 4($sp)
		lw   $a1, 8($sp)
		li   $a2, 8
		addi $a1, $a1, 40
		bge  $a1, 226, Goalie_Stay
		li   $a3, 8
		li   $s0, 8
		jal  Color_Bar
		lw   $ra, 0($sp)
		lw   $a1, 8($sp)
		addi $a1, $a1, 8
		sw   $a1, 8($sp)
	Goalie_Stay:
		lw   $a0, 4($sp)
		lw   $a1, 8($sp)
		li   $a2, 8
		li   $a3, 8
		li   $s0, 40
		jal  Color_Bar
		li   $a3, 0
		lw   $a1, 8($sp)
		lw   $ra, 0($sp)
		addi $sp, $sp, 20
		jr   $ra
        
# Procedure : Title_Screen
# Purpose   : To output a title screen to the bitmap display 
Title_Screen:
	subi $sp, $sp, 4
	sw   $ra, 0($sp)
	
	li   $a0, 56
	li   $a1, 40
	li   $a2, 7
	li   $a3, 400
	li   $s0, 18
	jal  Color_Bar
	li   $a0, 56
	li   $a1, 58
	li   $a2, 6
	li   $a3, 400
	li   $s0, 18
	jal  Color_Bar
	li   $a0, 56
	li   $a1, 76
	li   $a2, 3
	li   $a3, 400
	li   $s0, 18
	jal  Color_Bar
	
	li   $a0, 56
	li   $a1, 94
	li   $a2, 8
	li   $a3, 9
	li   $s0, 55
	jal  Color_Bar
	li   $a0, 56
	li   $a1, 94
	li   $a2, 8
	li   $a3, 90
	li   $s0, 9
	jal  Color_Bar
	li   $a0, 56
	li   $a1, 117
	li   $a2, 8
	li   $a3, 90
	li   $s0, 9
	jal  Color_Bar
	li   $a0, 137
	li   $a1, 94
	li   $a2, 8
	li   $a3, 9
	li   $s0, 27
	jal  Color_Bar
	
	li   $a0, 156
	li   $a1, 94
	li   $a2, 8
	li   $a3, 90
	li   $s0, 9
	jal  Color_Bar
	li   $a0, 156
	li   $a1, 94
	li   $a2, 8
	li   $a3, 9
	li   $s0, 55
	jal  Color_Bar
	li   $a0, 237
	li   $a1, 94
	li   $a2, 8
	li   $a3, 9
	li   $s0, 55
	jal  Color_Bar
	li   $a0, 156
	li   $a1, 140
	li   $a2, 8
	li   $a3, 90
	li   $s0, 9
	jal  Color_Bar
	
	li   $a0, 256
	li   $a1, 94
	li   $a2, 8
	li   $a3, 26
	li   $s0, 55
	jal  Color_Bar
	li   $a0, 273
	li   $a1, 94
	li   $a2, 8
	li   $a3, 55
	li   $s0, 9
	jal  Color_Diagonal_Bar
	li   $a0, 328
	li   $a1, 94
	li   $a2, 8
	li   $a3, 27
	li   $s0, 55
	jal  Color_Bar
	
	li   $a0, 366
	li   $a1, 94
	li   $a2, 8
	li   $a3, 9
	li   $s0, 55
	jal  Color_Bar
	li   $a0, 366
	li   $a1, 94
	li   $a2, 8
	li   $a3, 90
	li   $s0, 9
	jal  Color_Bar
	li   $a0, 447
	li   $a1, 94
	li   $a2, 8
	li   $a3, 9
	li   $s0, 8
	jal  Color_Bar
	li   $a0, 366
	li   $a1, 140
	li   $a2, 8
	li   $a3, 90
	li   $s0, 9
	jal  Color_Bar
	li   $a0, 447
	li   $a1, 121
	li   $a2, 8
	li   $a3, 9
	li   $s0, 28
	jal  Color_Bar
	li   $a0, 411
	li   $a1, 121
	li   $a2, 8
	li   $a3, 45
	li   $s0, 9
	jal  Color_Bar
	
	li   $a0, 56
	li   $a1, 149
	li   $a2, 3
	li   $a3, 400
	li   $s0, 18
	jal  Color_Bar
	li   $a0, 56
	li   $a1, 167
	li   $a2, 6
	li   $a3, 400
	li   $s0, 18
	jal  Color_Bar
	li   $a0, 56
	li   $a1, 185
	li   $a2, 7
	li   $a3, 400
	li   $s0, 18
	jal  Color_Bar
	
	li   $a0, 56
	li   $a1, 208
	la   $a2, Menu_Selc
	jal  OutText
	
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr   $ra
	
# Procedure : DrawBoard
# Purpose   : Draws the field in which game will be played
DrawBoard:
	subi $sp, $sp, 4
	sw   $ra, 0($sp)
	
	li $a0, 80
	li $a1, 25
	li $a2, 8
	li $a3, 352
	li $s0, 5
	jal Color_Bar
	li $a0, 80
	li $a1, 25
	li $a2, 8
	li $a3, 5
	li $s0, 206
	jal Color_Bar
	li $a0, 80
	li $a1, 226
	li $a2, 8
	li $a3, 352
	li $s0, 5
	jal Color_Bar
	li $a0, 427
	li $a1, 25
	li $a2, 8
	li $a3, 5
	li $s0, 206
	jal Color_Bar
	
	li $a0, 5
	li $a1, 25
	la $a2, Score_Prompt
	jal OutText
	li $a0, 437
	li $a1, 25
	la $a2, Score_Prompt
	jal OutText
	
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr   $ra
	
########################################################################
#                         CLEAR SCREENS                                #
########################################################################

# Procedure : Clear_Title_Screen
# Purpose   : To clear the content provided by the title screen
Clear_Title_Screen:
	subi $sp, $sp, 4
	sw   $ra, 0($sp)
	
	li   $a0, 56
	li   $a1, 40
	li   $a2, 0
	li   $a3, 400
	li   $s0, 18
	jal  Color_Bar
	li   $a0, 56
	li   $a1, 58
	li   $a2, 0
	li   $a3, 400
	li   $s0, 18
	jal  Color_Bar
	li   $a0, 56
	li   $a1, 76
	li   $a2, 0
	li   $a3, 400
	li   $s0, 18
	jal  Color_Bar
	
	li   $a0, 56
	li   $a1, 94
	li   $a2, 0
	li   $a3, 9
	li   $s0, 55
	jal  Color_Bar
	li   $a0, 56
	li   $a1, 94
	li   $a2, 0
	li   $a3, 90
	li   $s0, 9
	jal  Color_Bar
	li   $a0, 56
	li   $a1, 117
	li   $a2, 0
	li   $a3, 90
	li   $s0, 9
	jal  Color_Bar
	li   $a0, 137
	li   $a1, 94
	li   $a2, 0
	li   $a3, 9
	li   $s0, 27
	jal  Color_Bar
	
	li   $a0, 156
	li   $a1, 94
	li   $a2, 0
	li   $a3, 90
	li   $s0, 9
	jal  Color_Bar
	li   $a0, 156
	li   $a1, 94
	li   $a2, 0
	li   $a3, 9
	li   $s0, 55
	jal  Color_Bar
	li   $a0, 237
	li   $a1, 94
	li   $a2, 0
	li   $a3, 9
	li   $s0, 55
	jal  Color_Bar
	li   $a0, 156
	li   $a1, 140
	li   $a2, 0
	li   $a3, 90
	li   $s0, 9
	jal  Color_Bar
	
	li   $a0, 256
	li   $a1, 94
	li   $a2, 0
	li   $a3, 26
	li   $s0, 55
	jal  Color_Bar
	li   $a0, 273
	li   $a1, 94
	li   $a2, 0
	li   $a3, 55
	li   $s0, 9
	jal  Color_Diagonal_Bar
	li   $a0, 328
	li   $a1, 94
	li   $a2, 0
	li   $a3, 27
	li   $s0, 55
	jal  Color_Bar
	
	li   $a0, 366
	li   $a1, 94
	li   $a2, 0
	li   $a3, 9
	li   $s0, 55
	jal  Color_Bar
	li   $a0, 366
	li   $a1, 94
	li   $a2, 0
	li   $a3, 90
	li   $s0, 9
	jal  Color_Bar
	li   $a0, 447
	li   $a1, 94
	li   $a2, 0
	li   $a3, 9
	li   $s0, 8
	jal  Color_Bar
	li   $a0, 366
	li   $a1, 140
	li   $a2, 0
	li   $a3, 90
	li   $s0, 9
	jal  Color_Bar
	li   $a0, 447
	li   $a1, 121
	li   $a2, 0
	li   $a3, 9
	li   $s0, 28
	jal  Color_Bar
	li   $a0, 411
	li   $a1, 121
	li   $a2, 0
	li   $a3, 45
	li   $s0, 9
	jal  Color_Bar
	
	li   $a0, 56
	li   $a1, 149
	li   $a2, 0
	li   $a3, 400
	li   $s0, 18
	jal  Color_Bar
	li   $a0, 56
	li   $a1, 167
	li   $a2, 0
	li   $a3, 400
	li   $s0, 18
	jal  Color_Bar
	li   $a0, 56
	li   $a1, 185
	li   $a2, 0
	li   $a3, 400
	li   $s0, 18
	jal  Color_Bar
	
	li   $a0, 56
	li   $a1, 208
	la   $a2, 0
	li   $a3, 400
	li   $s0, 18
	jal  Color_Bar
	
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr   $ra
	
# Procedure : Clear_Field
# Purpose   : Clear the playing field for a new game
Clear_Field:
	subi $sp, $sp, 4
	sw   $ra, 0($sp)
	li   $a0, 85
	li   $a1, 30
	li   $a2, 0
	li   $a3, 342
	li   $s0, 196
	jal  Color_Bar
	li   $a0, 5
	li   $a1, 40
	li   $a2, 0
	li   $a3, 70
	li   $s0, 50
	jal  Color_Bar
	li   $a0, 432
	li   $a1, 40
	li   $a2, 0
	li   $a3, 70
	li   $s0, 50
	jal  Color_Bar
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr   $ra
	
# Procedure : Clear_Field
# Purpose   : Clear the playing field for a new game
Clear_Field2:
	subi $sp, $sp, 4
	sw   $ra, 0($sp)
	li   $a0, 5
	li   $a1, 25
	li   $a2, 0
	li   $a3, 507
	li   $s0, 231
	jal  Color_Bar
	lw   $ra, 0($sp)
	addi $sp, $sp, 4
	jr   $ra
