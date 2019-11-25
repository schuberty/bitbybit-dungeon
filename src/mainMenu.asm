.globl start

.data
stringWelcome:	.asciiz "        Bit by Bit: A Dungeon Game\n\n            Trabalho Final de AOC I\nDesenvolvido por: Gabriel Schubert M."
stringConfig:	.ascii  "    Settings do MARS necessárias,\nfora do padrão:\n\n1. Assemble all files in directory;\n2. Initialize Program Counter to\n  global \"main\" if defined;\n3. Self-modifying code."
		.asciiz	"\n\n    Tools necessárias:\n1. Bitmap Display conectado tendo:\n   - Unit Width e Height em 8;\n   - Display Width em 512;\n   - Display Height em 256;\n   - Base address na HEAP.\n2. MMIO Simulator conectado."
stringMMIO:	.ascii  "    Modo de uso do Keyboard MMIO Simulator:\n1. Teclas W e S para movimentação vertical;\n2. Teclas A e D para movimentação horizental;\n3. Tecla E para enter ou ação;\n4. Tecla Q para voltar ou parar movimentação."
		.asciiz "\n                    (! Teclas em lowercase !)\n\n    A partir de agora será apenas usado o MMIO\nSimulator e o Bitmap Display.\n\n                          BOM JOGO!"

menuHeader:	.asciiz "\tBit by Bit Dungeon MENU:\nSelect"

.text
start:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)
	
	jal   msg_Config
	jal   MMIO_MainMenu
	jal   msg_Prologue
	
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra
	
#########################################
# 					#
msg_Config:
	li    $v0, 55
	li    $a1, 1
	la    $a0, stringWelcome
	syscall
	la    $a0, stringConfig
	syscall
	la    $a0, stringMMIO
	syscall
	jr    $ra
#########################################
#					#
MMIO_MainMenu:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)
	lui   $t0, 0xffff
	li    $t1, 1
	sb    $t1, 8($t0)
	add   $t1, $t1, 11
	sw    $t1, 12($t0)
	la    $a1, menuHeader
	jal   MMIO_ToString
	li    $v0, 31
	li    $a0, 40
	li    $a1, 5000
	li    $a2, 100
	li    $a3, 27
	syscall

	
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra
	
	
#########################################
#					#
MMIO_ToString:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)
toStringLoop:
	lb    $a0, ($a1)
	jal   MMIO_SendChar
	addi  $a1, $a1, 1
	bnez  $a0, toStringLoop
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra

#########################################
#					#
MMIO_SendChar:
	lui   $a3, 0xffff
sendCursor:
	lw    $t1, 8($a3)
	andi  $t1, $t1, 1
	beqz  $t1, sendCursor
	sw    $a0, 12($a3)
	jr    $ra
#########################################
#					#
msg_Prologue:
	jr    $ra