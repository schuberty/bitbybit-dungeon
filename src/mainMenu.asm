.globl display_Menus,MMIO_sendToDisplay,MMIO_sendChar,MMIO_getChar,selectedOpt,printSelection

.data
# Data com strings que aparecem nos dialogs inicias
stringWelcome:	.asciiz "        Bit by Bit: A Dungeon Game\n\n            Trabalho Final de AOC I\nDesenvolvido por: Gabriel Schubert M."
stringConfig:	.ascii  "    Settings do MARS necessárias,\nfora do padrão:\n\n1. Assemble all files in directory;\n2. Initialize Program Counter to\n  global \"main\" if defined;\n3. Self-modifying code."
		.asciiz	"\n\n    Tools necessárias:\n1. Bitmap Display conectado tendo:\n   - Unit Width e Height em 8;\n   - Display Width em 512;\n   - Display Height em 256;\n   - Base address na HEAP.\n2. MMIO Simulator conectado."
stringMMIO:	.ascii  "    Modo de uso do Keyboard MMIO Simulator:\n1. Teclas W e S para movimentação vertical;\n2. Teclas A e D para movimentação horizental;\n3. Tecla ESPAÇO para enter ou ação."
		.asciiz "\n\n                          BOM JOGO!"
# Data com strings que aparecem no menu principal
menuHeader:	.asciiz "\tBit by Bit Dungeon MENU:\n\n"
menuOpt1:	.asciiz "\t   Entrar na Masmorra\n"
menuOpt2:	.asciiz "\t Selecionar Dificuldade\n"
menuOpt3:	.asciiz "\t      Sair do Menu\n\n Dificuldade atual : "
selectedOpt:	.asciiz "      >"
# Data com strings do menu de seleção de dificuldade
diffMenuHeader:	.asciiz "\tSelecione a dificuldade:\n\n"
diffMenuOpt1:	.asciiz "\t       Fácil\n"
diffMenuOpt2:	.asciiz "\t       Médio\n"
diffMenuOpt3:	.asciiz "\t      Díficil\n"
diffMenuBack:	.ascii  "\t  Voltar pro menu"
diffMenuSubt:	.asciiz "\n\n Fácil   : +50 de experiência ganha\n Médio   : Ganho normal de experiência\n Difícil : -50% de experiência ganha"
diffEasy:	.asciiz "Fácil"
diffNormal:	.asciiz "Médio"
diffHard:	.asciiz "Difícil"

playerGetName:	.asciiz ""
playerGetColor: .asciiz ""

.text
display_Menus:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)
	
	jal   msg_Config
	jal   MMIO_MainMenu
	
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra
#########################################################
# -Mostra as três janelas pop-up de ínicio do programa	#
msg_Config:						#
	li    $v0, 55					# Valor de InputDialogInt
	li    $a1, 1					# Valor de Information Window
	la    $a0, stringWelcome			# Começa a mostrar as janelas
	syscall
	la    $a0, stringConfig
	syscall
	la    $a0, stringMMIO
	syscall
	jr    $ra					# Retorna
#########################################################
# -Mostra o menu principal, para o jogador, com opções	#
# de inciar a masmorra, selecionar dificuldade ou sair	#
MMIO_MainMenu:
	addiu $sp, $sp, -4				# Pilha para o retorno
	sw    $ra, ($sp)
	lui   $t0, 0xffff				# Valor do Transmitter Controller Ready bit
	li    $t1, 1					# Posicionado para 1 manualmente
	sb    $t1, 8($t0)				# E armazenado na posição especifica
	li    $t2, 0					# Valor salvo pro Ready Transmitter
	li    $t3, 1					# Valor inicial da opção do menu selecionada
	add   $t1, $t1, 11				# Incrementa para ser o valor 12 que da clear no MMIO Display
	mainMenuSelection:
		sw    $t1, 12($t0)			# Armazena o valor para dar clear
		la    $a1, menuHeader			# Valor á enviar na MMIO Display
		jal   MMIO_sendToDisplay
#		sw    $zero, 4($t0)
		li    $t4, 1				# Valor para checar se a seta vai nesta posição
		jal   printSelection			# Imprime a seta, caso seja nesta posição
		la    $a1, menuOpt1			# Carrega a opção do menu
		jal   MMIO_sendToDisplay		# Envia a opção do menu
		li    $t4, 2
		jal   printSelection
		la    $a1, menuOpt2
		jal   MMIO_sendToDisplay	
		li    $t4, 3
		jal printSelection
		la    $a1, menuOpt3
		jal   MMIO_sendToDisplay
		jal   printDifficult			# Mostra a dificuldade no menu principal
		anyMainKeySelected:
		jal   MMIO_getChar			# Pega o char digitado pelo MMIO Keyboard
		beq   $v0, ' ', mainKeyEnter		# Checa qual foi o char digitado para executar uma ação
		beq   $v0, 'w', mainKeyUp
		beq   $v0, 'W', mainKeyUp
		beq   $v0, 's', mainKeyDown
		beq   $v0, 'S', mainKeyDown
	j     anyMainKeySelected			# Loop até um char válido ser digitado
	

#-------#################################################
	# -Ações dependendo do char selecionado		#
	# @param $t3 : int, posição no menu		#
	mainKeyDown:					# Posiciona a seta para baixo, se não for o limite
	bge   $t3, 3, anyMainKeySelected		# Se for o limite no menu
	add   $t3, $t3, 1				# Se não for, incrementa o registrador do menu
	j     mainMenuSelection				# Volta pro menu
	mainKeyUp:					# Posiciona a seta para cima, se não for o limite
	ble   $t3, 1, anyMainKeySelected
	add   $t3, $t3, -1
	j     mainMenuSelection
	mainKeyEnter:					# Executa a opção atual selecionada
	beq   $t3, 2, MMIO_DifficultMenu		# Se for 2, menu de mudar dificuldade
	beq   $t3, 3, stop				# Se for 3, saí do programa
	lw    $ra, ($sp)				# Se for 1, entra na masmorra no nível 1
	addiu $sp, $sp, 4				#
	jr    $ra					# Retorna da pilha
#########################################################
# -Menu para mudar dificuldade almejada			#
MMIO_DifficultMenu:
	addiu $sp, $sp, -4				# Pilha para o retorno
	sw    $ra, ($sp)
	
	li    $t3, 1
	difficultSelection:				# Loop para selecionar a dificuldade
		sw    $t1, 12($t0)			# Clear
		la    $a1, diffMenuHeader
		jal   MMIO_sendToDisplay
		li    $t4, 1
		jal   printSelection
		la    $a1, diffMenuOpt1
		jal   MMIO_sendToDisplay
		li    $t4, 2
		jal   printSelection
		la    $a1, diffMenuOpt2
		jal   MMIO_sendToDisplay
		li    $t4, 3
		jal   printSelection
		la    $a1, diffMenuOpt3
		jal   MMIO_sendToDisplay
		li    $t4, 4
		jal   printSelection
		la    $a1, diffMenuBack
		jal   MMIO_sendToDisplay
		anyDiffKeySelected:
		jal   MMIO_getChar			# Pega o char digitado pelo MMIO Keyboard
		beq   $v0, ' ', diffKeyEnter		# Checa qual foi o char digitado para executar uma ação
		beq   $v0, 'w', diffKeyUp
		beq   $v0, 'W', diffKeyUp
		beq   $v0, 's', diffKeyDown
		beq   $v0, 'S', diffKeyDown
	j     anyDiffKeySelected
	diffBackOption:					# Volta para o menu principal
	li    $t3, 1					# Local da seta no menu principal
	lw    $ra, ($sp)				# Atualiza a pilha
	addiu $sp, $sp, 4
	j     mainMenuSelection				# Retorna pro menu principal
#-------#################################################
	# -Ações dependendo do char selecionado		#
	# @param $t3 : int, posição no menu		#
	diffKeyDown:					# Posiciona a seta para baixo, se não for o limite
	bge   $t3, 4, anyDiffKeySelected		# Se for o limite no menu
	add   $t3, $t3, 1				# Se não for, incrementa o registrador do menu
	j     difficultSelection			# Volta pro menu
	diffKeyUp:					# Posiciona a seta para cima, se não for o limite
	ble   $t3, 1, anyDiffKeySelected
	add   $t3, $t3, -1
	j     difficultSelection
	diffKeyEnter:					# Executa a opção atual selecionada
	beq   $t3, 4, diffBackOption			# Volta para o menu principal
	la    $t4, gameSettings				# Carrega local da configuração
	sw    $t3, 0($t4)				# Salva a dificuldade na configuração
	j     diffBackOption				# Muda a dificuldade
#-------#################################################
	# -Mostra a dificuldade no menu principal	#
	# @param $t3 : int, posição no menu		#
	printDifficult:
	addiu $sp, $sp, -4				# Pilha para o retorno
	sw    $ra, ($sp)
	la    $t4, gameSettings
	lw    $t4, 0($t4)
	beq   $t4, 1, printEasy
	beq   $t4, 3, printHard
	la    $a1, diffNormal
	jal   MMIO_sendToDisplay
	j     diffNext
	printEasy:
	la    $a1, diffEasy
	jal   MMIO_sendToDisplay
	j     diffNext
	printHard:
	la    $a1, diffHard
	jal   MMIO_sendToDisplay
	diffNext:
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra					# Retorno da pilha
#########################################################
# -Imprime a seta na opção selecionada			#
# @param $t3 : int, posição atual no menu		#
# @param $t4 : int, posição á testar			#
printSelection:
	addiu $sp, $sp, -4				# Pilha para o retorno
	sw    $ra, ($sp)
	sub   $t4, $t4, $t3				# Vê se o valor em $t4 equivale ao do reg. onde a opção está
	bnez  $t4, printNext				# Se não for, continua para voltar
	la    $a1, selectedOpt				# Se for, imprime a seta na opção selecionada
	jal   MMIO_sendToDisplay			# E envia pro display
	printNext:
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra					# Retorno da pilha
#########################################################
# -Percorre uma string para enviar ao MMIO Display	#
# @param $a1 : string 					#
MMIO_sendToDisplay:					#
	addiu $sp, $sp, -4				# Pilha para o retorno
	sw    $ra, ($sp)
	toDisplayLoop:
		lb    $a0, ($a1)			# Carrega char da string
		jal   MMIO_sendChar			# Envia
		addi  $a1, $a1, 1			# Proximo char da strings
	bnez  $a0, toDisplayLoop			# Enquanto não for fim da string
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra					# Retorna da pilha
#-------#################################################
	# -Envia o caractere para o MMIO Display	#
	# @param $a0 : char, valor ASCII		#
	MMIO_sendChar:	
		lui   $a3, 0xffff			# Carrega o endereço base do MMIO
		sendCursor:
			lw    $a2, 8($a3)		# Valor do Transmitter Controller Ready bit
			andi  $a2, $a2, 1		# Habilita a escrita no MMIO Display
		beqz  $a2, sendCursor			# Espera primeiro input pra estar disponível (RESET)
		sw    $a0, 12($a3)			# Envia o char pra posição de envio
		jr    $ra				# Retorna
#-------#################################################
	# -Intercepta um char pelo MMIO Keyboard	#
	# @param $v0 : char, valor ASCII		#
	MMIO_getChar:
		lui   $a1, 0xffff			# Carrega o endereço base
		inputReady:
			lw    $a2, 0($a1)		# Carrega o valor que checa se o MMIO Keyboard está
			andi  $a2, $a2, 0x1		# pronto para leitura de um char
		beqz  $a2, inputReady			# Se não estiver, volta até estar (método sem input lag)
		lw    $v0, 4($a1)			# Salva o char digitado em $v0
		jr    $ra				# Retorna
#########################################################
