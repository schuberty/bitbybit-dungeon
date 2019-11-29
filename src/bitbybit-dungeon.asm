.globl main,stop,zeroAll
.globl gameSettings,playerName

.data
# Vetor de configs.: {dificuldade, salaAtual,
gameSettings:	.word      2     ,    1
# Vetor do jogador:  {vidaMax, manaMax, ataqueMin, ataqueMax, defesaBase, defesaMaxGain, vitórias}
playerSettings:	.word    10  ,    5   ,     3    ,      6   ,     0     ,       2      ,    0
playerName:	.asciiz "Gabriel"
.text
main:
	jal  display_Menus
	jal  zeroAll
	jal  bitmapDisplay_Configuration
	jal  zeroAll
	jal  start_Game
	jal  stop
	
#########################################################
# -Function que zera todos os valores de registradores	#
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
	li   $t8, 0
	li   $t9, 0
	jr   $ra
#########################################################
# -Para o funcionamento do programa com syscall		#
stop:
	li   $v0, 17
	syscall
