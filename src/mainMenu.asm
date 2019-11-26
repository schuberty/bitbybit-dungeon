.globl start

.data
stringWelcome:	.asciiz "        Bit by Bit: A Dungeon Game\n\n            Trabalho Final de AOC I\nDesenvolvido por: Gabriel Schubert M."
stringConfig:	.ascii  "    Settings do MARS necessárias,\nfora do padrão:\n\n1. Assemble all files in directory;\n2. Initialize Program Counter to\n  global \"main\" if defined;\n3. Self-modifying code."
		.asciiz	"\n\n    Tools necessárias:\n1. Bitmap Display conectado tendo:\n   - Unit Width e Height em 8;\n   - Display Width em 512;\n   - Display Height em 256;\n   - Base address na HEAP.\n2. MMIO Simulator conectado."
stringMMIO:	.ascii  "    Modo de uso do Keyboard MMIO Simulator:\n1. Teclas W e S para movimentação vertical;\n2. Teclas A e D para movimentação horizental;\n3. Tecla E para enter ou ação;\n4. Tecla Q para voltar ou parar movimentação."
		.asciiz "\n                    (! Teclas em lowercase !)\n\n    A partir de agora será apenas usado o MMIO\nSimulator e o Bitmap Display.\n\n                          BOM JOGO!"

menuHeader:	.asciiz "\tBit by Bit Dungeon MENU:\nEscolha com W e S e selecione com E"

.text
start:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)
	
#	jal   msg_Config
	jal   MMIO_MainMenu
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
#########################################
# Mostra o Main Menu no inicio do 	#
MMIO_MainMenu:				#
	addiu $sp, $sp, -4		# Pilha pro retorno
	sw    $ra, ($sp)
	lui   $t0, 0xffff		# Valor do Transmitter Controller Ready bit
	li    $t1, 1			# Posicionado para 1 manualmente
	sb    $t1, 8($t0)		# E armazenado na posição especifica
	
	add   $t1, $t1, 11
	sw    $t1, 12($t0)		# ASCII 12 da clear na MMIO Display
	la    $a1, menuHeader		# Valor á enviar na MMIO Display
	jal   MMIO_sendToDisplay
	
	lw    $ra, ($sp)		# Retorno da pilha
	addiu $sp, $sp, 4
	jr    $ra
	
	
#########################################
# Processo de enviar string pro MMIO	#
# Endereço da string em $a1		#
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

#########################################
# Envia o char armazenado em $a0	#
MMIO_SendChar:				#
	li   $a3, 0xffff000C		# Carrega o endereço base
#sendCursor:				# Loop desabilitado, Transmitter bit habilitado em MMIO_MainMenu
#	lw    $t1, 8($a3)		# Valor do Transmitter Controller Ready bit
#	andi  $t1, $t1, 1		# Habilita a escrita no MMIO Display
#	beqz  $t1, sendCursor		# Espera primeiro input pra estar disponível (RESET)
	sw    $a0, ($a3)		# Envia o char pra posição de envio
	jr    $ra			# Retorna
#########################################
#					#
msg_Prologue:
	jr    $ra
