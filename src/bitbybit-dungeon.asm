.globl main,stop,zeroAll
.globl playerName

.data
playerName:	.space 64
#		     [HP,MP,Shield,NumHammers,ifHelmet,ifBody,ifLegs,ifShoes,ifSword,ifSpell]
playerAtt:	.word 20, 20, 0, 0, 0, 0, 0, 0, 0, 0
.text
main:
	jal  display_Menus
	jal  zeroAll
	jal  bitmapDisplay_Configuration
	jal  zeroAll
	jal  start_Game
	jal  stop
	
#########################################################
# Function que zera todos os valores de registradores	#
#							#
zeroAll:
	li   $v0, 0
	li   $v1, 0
	li   $a0, 0
	li   $a1, 0
	li   $a2, 0
	li   $a3, 0
	li   $t1, 0
	li   $t2, 0
	li   $t3, 0
	li   $t4, 0
	li   $t5, 0
	li   $t6, 0
	li   $t7, 0
	li   $s0, 0
	li   $s1, 0
	li   $s2, 0
	li   $s3, 0
	li   $s4, 0
	li   $s5, 0
	li   $s6, 0
	li   $s7, 0
	li   $t8, 0
	li   $t9, 0
	jr   $ra
#########################################
# Para o programa			#
stop:
	li   $v0, 17
	syscall
