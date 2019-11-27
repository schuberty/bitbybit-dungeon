.globl display_Menus,MMIO_sendToDisplay,MMIO_GetChar

.data
stringWelcome:	.asciiz "        Bit by Bit: A Dungeon Game\n\n            Trabalho Final de AOC I\nDesenvolvido por: Gabriel Schubert M."
stringConfig:	.ascii  "    Settings do MARS necessárias,\nfora do padrão:\n\n1. Assemble all files in directory;\n2. Initialize Program Counter to\n  global \"main\" if defined;\n3. Self-modifying code."
		.asciiz	"\n\n    Tools necessárias:\n1. Bitmap Display conectado tendo:\n   - Unit Width e Height em 8;\n   - Display Width em 512;\n   - Display Height em 256;\n   - Base address na HEAP.\n2. MMIO Simulator conectado."
stringMMIO:	.ascii  "    Modo de uso do Keyboard MMIO Simulator:\n1. Teclas W e S para movimentação vertical;\n2. Teclas A e D para movimentação horizental;\n3. Tecla E para enter ou ação;\n4. Tecla Q para voltar ou parar movimentação."
		.asciiz "\n\n                          BOM JOGO!"

stringMenu:	.asciiz  "\tBit by Bit Dungeon MENU:\n\n"
menuOpt1:	.asciiz "\t   Entrar na Masmorra\n"
menuOpt2:	.asciiz "\t Selecionar Dificuldade\n"
menuOpt3:	.asciiz "\t      Sair do Menu"
selectedOpt:	.asciiz "      >"



playerGetName:	.asciiz "Diga-me, aventureiro de uma terra distante chamada Pelota"
playerGetColor: .asciiz ""



.text
display_Menus:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)
	
	jal   msg_Config
	jal   MMIO_MainMenu
	jal   MMIO_GetPlayer
	jal   msg_Prologue
	
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra
	
#########################################
# Mostra 3 janelas de inicio		#
msg_Config:				#
	li    $v0, 55			# Valor de InputDialogInt
	li    $a1, 1			# Valor de Information Window
	la    $a0, stringWelcome	# Começa a mostrar as janelas
	syscall
	la    $a0, stringConfig
	syscall
	la    $a0, stringMMIO
	syscall
	jr    $ra
#########################################################
# -Mostra o menu principal, para o jogador, com opções	#
# de inciar a masmorra, selecionar dificuldade ou sair	#
MMIO_MainMenu:				#
	addiu $sp, $sp, -4		# Pilha pro retorno
	sw    $ra, ($sp)
	lui   $t0, 0xffff		# Valor do Transmitter Controller Ready bit
	li    $t1, 1			# Posicionado para 1 manualmente
	sb    $t1, 8($t0)		# E armazenado na posição especifica
	li    $t2, 0			# Valor salvo pro Ready Transmitter
	li    $t3, 1			# Valor inicial da opção do menu selecionada

	add   $t1, $t1, 11
menuSelection:
	sw    $t1, 12($t0)		# ASCII 12 da clear na MMIO Display
	la    $a1, stringMenu		# Valor á enviar na MMIO Display
	jal   MMIO_sendToDisplay
#	sw    $zero, 4($t0)
	li    $t4, 1
	jal   printSelection
	la    $a1, menuOpt1
	jal   MMIO_sendToDisplay
	li    $t4, 2
	jal   printSelection
	la    $a1, menuOpt2
	jal   MMIO_sendToDisplay
	li    $t4, 3
	jal printSelection
	la    $a1, menuOpt3
	jal   MMIO_sendToDisplay
	jal   MMIO_GetChar
	beq   $v0, 'e', keyEnter
	beq   $v0, 'E', keyEnter
	beq   $v0, 'w', keyUp
	beq   $v0, 'W', keyUp
	beq   $v0, 's', keyDown
	beq   $v0, 'S', keyDown
	j     menuSelection

keyDown:
	bge   $t3, 3, menuSelection
	add   $t3, $t3, 1
	j     menuSelection
keyUp:
	ble   $t3, 1, menuSelection
	add   $t3, $t3, -1
	j     menuSelection
changeDifficult:
	j     menuSelection
printSelection:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)

	sub   $t4, $t4, $t3
	bnez  $t4, printNext
	la    $a1, selectedOpt
	jal   MMIO_sendToDisplay
printNext:
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra
keyEnter:
	beq   $t3, 2, changeDifficult
	beq   $t3, 3, stop
	lw    $ra, ($sp)		# Retorno da pilha
	addiu $sp, $sp, 4
	jr    $ra
	
#########################################################
# -Percorre uma string para enviar ao MMIO Display	#
# @param $a1 : string 					#
MMIO_sendToDisplay:			#
	addiu $sp, $sp, -4		# Pilha pro retorno
	sw    $ra, ($sp)
toDisplayLoop:
	lb    $a0, ($a1)		# Carrega char da string
	jal   MMIO_SendChar		# Envia
	addi  $a1, $a1, 1		# Proximo char da strings
	bnez  $a0, toDisplayLoop	# Enquanto não for fim da string
	lw    $ra, ($sp)		# Retorna da pilha
	addiu $sp, $sp, 4
	jr    $ra

#########################################################
# Envia o caractere especificado para o MMIO Display	#
# @param $a0 : char, valor ASCII			#
MMIO_SendChar:				#
	lui   $a3, 0xffff		# Carrega o endereço base
sendCursor:				# Loop desabilitado, Transmitter bit habilitado em MMIO_MainMenu
	lw    $t2, 8($a3)		# Valor do Transmitter Controller Ready bit
	andi  $t2, $t2, 1		# Habilita a escrita no MMIO Display
	beqz  $t2, sendCursor		# Espera primeiro input pra estar disponível (RESET)
	sw    $a0, 12($a3)		# Envia o char pra posição de envio
	jr    $ra			# Retorna
#########################################################
# -Intercepta um caractere enviado pelo MMIO Keyboard	#
# @return $v0 : char, valor ASCII			#							#
MMIO_GetChar:
	lui   $a1, 0xffff
inputReady:
	lw    $a2, 0($a1)
	andi  $a2, $a2, 0x1
	beqz  $a2, inputReady
	lw    $v0, 4($a1)
	jr    $ra
#########################################################
# -Intercepta um caractere enviado pelo MMIO Keyboard	#
# @return $v0 : char, valor ASCII		#
MMIO_GetPlayer:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)
	
getNameLoop:

	
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra
#########################################################
# -Intercepta um caractere enviado pelo MMIO Keyboard	#
# @return $v0 : Valor ASCII do caractere		#
msg_Prologue:
	jr    $ra
