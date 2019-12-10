.globl main,stop,zeroAll
.globl gameSettings,playerSettings,playerName

.data
# Vetor de configs.: {dificuldade, salaAtual, decrementadorSala, vitorias
gameSettings:	.word      2     ,    1     ,         0        ,    0
# Vetor do jogador:  {vida ,  vidaMax,  mana  ,manaMax, ataqueMin, ataqueMax, defesaBase, defesaMax, exp, expNextLevel, temEscada}
playerSettings:	.word  10  ,   20    ,   5    ,   5   ,     3    ,      6   ,     0     ,     2    ,  0 ,      50     ,     3
playerName:	.space 60
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
