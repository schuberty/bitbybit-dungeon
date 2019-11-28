.globl start_Game

.data
beginHeader:	.asciiz "\t["
endHeader:	.asciiz "]\n\n"

movHeader:	.asciiz " está Explorando a Sala "
movKeys1:	.ascii  " (E-e) : Sentar no chão\n"
movKeys2:	.ascii  " (W-w) : Ir para cima\n"
movKeys3:	.ascii  " (S-s) : Ir para baixo\n"
movKeys4:	.ascii  " (A-a) : Ir para a esquerda\n"
movKeys5:	.asciiz " (D-d) : Ir para a direita\n"


battleHeader:	.asciiz " está em Batalha]\n\n"
battleOpt1:	.asciiz "\t      Atacar\n"
battleOpt2:	.asciiz "\t    Usar magia\n"
battleOpt3:	.asciiz "\t       Sair"
.text
start_Game:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)
	
	jal   Player_Movement
	jal   zeroAll
	jal   Enter_Battle
	
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra

#########################################################
# -Realiza o movimento do jogador pela sala		#
# @return : quando encontra um inimigo ou;		#
# @return : quando descobre um buraco na parede.	#
Player_Movement:
	addiu $sp, $sp, -4		# Pilha pro retorno
	sw    $ra, ($sp)
	
	li    $t0, 0xffff000C		# MMIO Display 
	li    $t1, 12
	sw    $t1, ($t0)		# Clear
	la    $a1, beginHeader		# Começa a mostrar as opções de movimento
	jal   MMIO_sendToDisplay
	la    $a1, playerName
	jal   MMIO_sendToDisplay
	la    $a1, movHeader
	jal   MMIO_sendToDisplay
	lw    $a0, gameSettings+4
	add   $a0, $a0, 48
	jal   MMIO_sendChar
	la    $a1, endHeader
	jal   MMIO_sendToDisplay
	la    $a1, movKeys1
	jal   MMIO_sendToDisplay

	move  $t0, $s0			# Posição do aventureiro
	li    $t1, 0x8237D6		# Cor do aventureiro
	li    $t2, 0xB8B06C		# Cor por onde andou
	sw    $t1, ($t0)		# Gera o aventureiro
	add   $t0, $t0, 4
	sw    $t1, ($t0)
	add   $t0, $t0, 252
	sw    $t1, ($t0)
	add   $t0, $t0, 4
	sw    $t1, ($t0)

	movementLoop:				# Começa toda a função de mover o jogador e checar pixels
		beqz  $t6, keepMoving		# Checa se entrou nas sombras
		j     checkShadow		# Se entrou, checa se ha algum inimigo
		keepMoving:
		jal   MMIO_getChar		# Em $v0 está o valor ASCII de movimento
		move  $t3, $v0			# Salva o valor
		beq   $t3, 'q', stop
		beq   $t3, 'Q', stop
		move  $t0, $s0			# Pega a posição atual do jogador
		beq   $t3, 'a', moveHorizontal
		beq   $t3, 'A', moveHorizontal
		beq   $t3, 'd', moveHorizontal
		beq   $t3, 'D', moveHorizontal
		beq   $t3, 'w', moveVertical
		beq   $t3, 'W', moveVertical
		beq   $t3, 's', moveVertical
		beq   $t3, 'S', moveVertical
	j     movementLoop
	foundedEnemy:
	lw    $ra, ($sp)		# Retorno da pilha
	addiu $sp, $sp, 4
	jr    $ra					# Retorno da pilha
#-------#################################################
	# -Checa se esta na sombra e se estiver checa	#
	# se ha algum inimigo nela			#
	# @return : se não houver inimigo		#
	walkInShadow:
		bne   $t5, 0xA59E62, notInShadow
		add   $t6, $t6, 1
		notInShadow:
		jr    $ra
	checkShadow:
		li    $t5, 8				# Dividor do random int gerado é a chance de ter inimigo na sombra atual [5,20]
		li    $v0, 41				# Random int code
		syscall
		div   $a0, $t5
		mfhi  $t5				# Armazena o resto da divisão
		beqz  $t5, foundedEnemy			# Se for igual a zero, tem um inimigo e entra em batalha
		add   $t6, $t6, -1
		j     keepMoving			# Retorna
#-------#################################################
	# -Movem o jogador para a direção especificada	#
	# ou abre o menu em movimento			#
	# @param $a0 : char, valor ASCII interceptado	#
	moveHorizontal:
		subi  $t4, $t3, 'a'
		beqz  $t4, moveLeft
		subi  $t4, $t3, 'A'
		beqz  $t4, moveLeft
		addi  $t0, $t0, 8			# Movimento para a direita
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop	# Se for uma parede
		jal   walkInShadow			# Testa se esta entrando na sombra
		addi  $t0, $t0, 256
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop
		jal   walkInShadow
		sw    $t1, ($t0)			# Move o jogador
		addi  $t0, $t0, -8
		sw    $t2, ($t0)
		addi  $t0, $t0, -256
		sw    $t2, ($t0)
		addi  $t0, $t0, 8
		sw    $t1, ($t0)
		addi  $t0, $t0, -4
		move  $s0, $t0				# Salva a nova posição
		j     movementLoop
		moveLeft:
		addi  $t0, $t0, -4			# Movimento para a esquerda
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop
		jal   walkInShadow
		addi  $t0, $t0, 256
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop
		jal   walkInShadow
		sw    $t1, ($t0)			# Move o jogador
		addi  $t0, $t0, 8
		sw    $t2, ($t0)
		addi  $t0, $t0, -256
		sw    $t2, ($t0)
		addi  $t0, $t0, -8
		sw    $t1, ($t0)
		move  $s0, $t0				# Salva a nova posição
		j     movementLoop
	moveVertical:
		subi  $t4, $t3, 's'
		beqz  $t4, moveDown
		subi  $t4, $t3, 'S'
		beqz  $t4, moveDown
		addi  $t0, $t0, -252			# Movimento para cima
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop
		jal   walkInShadow
		addi  $t0, $t0, -4
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop
		jal   walkInShadow
		move  $s0, $t0				# Salva a nova posição
		sw    $t1, ($t0)			# Move o jogador
		addi  $t0, $t0, 4
		sw    $t1, ($t0)
		addi  $t0, $t0, 508
		sw    $t2, ($t0)
		addi  $t0, $t0, 4
		sw    $t2, ($t0)
		j     movementLoop
		moveDown:
		addi  $t0, $t0, 512			# Movimento para baixo
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop
		jal   walkInShadow
		addi  $t0, $t0, 4
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop
		jal   walkInShadow
		sw    $t1, ($t0)			# Move o jogador
		addi  $t0, $t0, -4
		sw    $t1, ($t0)
		addi  $t0, $t0, -508
		sw    $t2, ($t0)
		addi  $t0, $t0, -4
		sw    $t2, ($t0)
		addi  $t0, $t0, 256
		move  $s0, $t0				# Salva a nova posição
		j     movementLoop			# Retorna
	doAction:
		j     movementLoop
#########################################################
# -Inicia o combate com um inimigo			#
# @return : quando o jogador ou o inimigo morre		#
Enter_Battle:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)

	lui   $t0, 0xffff
	li    $t1, 12
	li    $t3, 1
menuSelection:
	sw    $t1, 12($t0)
	la    $a1, beginHeader
	jal   MMIO_sendToDisplay
	la    $a1, playerName
	jal   MMIO_sendToDisplay
	la    $a1, battleHeader
	jal   MMIO_sendToDisplay
	li    $t4, 1
	jal   printSelection
	la    $a1, battleOpt1
	jal   MMIO_sendToDisplay
	li    $t4, 2
	jal   printSelection
	la    $a1, battleOpt2
	jal   MMIO_sendToDisplay
	li    $t4, 3
	jal   printSelection
	la    $a1, battleOpt3
	jal   MMIO_sendToDisplay
#	jal   printStatus
	jal   MMIO_getChar
	beq   $v0, 'e', keyEnter
	beq   $v0, 'E', keyEnter
	beq   $v0, 'w', keyUp
	beq   $v0, 'W', keyUp
	beq   $v0, 's', keyDown
	beq   $v0, 'S', keyDown
	j     menuSelection
#-------#################################################
	# -Ações dependendo do char selecionado		#
	# @param $t3 : int, posição no menu		#
	keyDown:
	bge   $t3, 3, menuSelection
	add   $t3, $t3, 1
	j     menuSelection
	keyUp:
	ble   $t3, 1, menuSelection
	add   $t3, $t3, -1
	j     menuSelection
	keyEnter:
	beq   $t3, 1, attackEnemy
#	beq   $t4, 2, magicMenu
	beq   $t3, 3, keyExit
	lw    $ra, ($sp)		# Retorno da pilha
	addiu $sp, $sp, 4
	jr    $ra
	keyExit:
	lw    $ra, ($sp)
	addiu $sp, $sp 4
	jr    $ra

#-------#################################################
	# -Realiza o ataque no inimigo			#
	attackEnemy:
		j     menuSelection
