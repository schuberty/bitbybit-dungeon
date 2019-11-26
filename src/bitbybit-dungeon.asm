.globl main,stop
.globl playerName,playerColor

.data
playerName:	.space 64
playerColor:	.space 4
.text
main:
	jal  display_Menus
	jal  bitmapDisplay_Configuration
	jal  start_Game
	jal  stop
#########################################
# Stop the program			#
stop:
	li   $v0, 17
	syscall
