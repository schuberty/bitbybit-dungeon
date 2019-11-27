.globl start_Game

.data

.text
start_Game:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)
	
	jal   Player_Movement
	
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra

#########################################################
# -Realiza o movimento do jogador pela sala		#
# @return : quando encontra um inimigo ou;		#
# @return : quando descobre um buraco na parede.
Player_Movement:
	addiu $sp, $sp, -4		# Pilha pro retorno
	sw    $ra, ($sp)
	
	
	lui   $s0, 0x1004
	addi  $s0, $s0, 1296
	move  $t0, $s0
	li    $t1, 0x8237D6		# Cor do aventureiro
	li    $t2, 0xB8B06C		# Cor por onde andou
	sw    $t1, ($t0)		# Gera o aventureiro
	add   $t0, $t0, 4
	sw    $t1, ($t0)
	add   $t0, $t0, 252
	sw    $t1, ($t0)
	add   $t0, $t0, 4
	sw    $t1, ($t0)
	
movementLoop:
	jal   MMIO_GetChar		# Em $v0 está o valor ASCII de movimento
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
	jr    $ra

#-------#################################################
	# -Movem o jogador para a direção especificada,	#
	# realiza uma ação ou saí do jogo		#
	# @param $a0 : char, valor ASCII interceptado	#
	moveHorizontal:
		subi  $t4, $t3, 'a'
		beqz  $t4, moveLeft
		subi  $t4, $t3, 'A'
		beqz  $t4, moveLeft

		addi  $t0, $t0, 8
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop	# Se for uma parede
		beq   $t5, 0xFF0000, foundedEnemy	# Se for um inimigo
		addi  $t0, $t0, 256
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop	# Se for uma parede
		beq   $t5, 0xFF0000, foundedEnemy	# Se for um inimigo
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
		addi  $t0, $t0, -4
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop
		beq   $t5, 0xFF0000, foundedEnemy
		addi  $t0, $t0, 256
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop
		beq   $t5, 0xFF0000, foundedEnemy
		sw    $t1, ($t0)
		addi  $t0, $t0, 8
		sw    $t2, ($t0)
		addi  $t0, $t0, -256
		sw    $t2, ($t0)
		addi  $t0, $t0, -8
		sw    $t1, ($t0)
		move  $s0, $t0
		
		j     movementLoop

	moveVertical:
		subi  $t4, $t3, 's'
		beqz  $t4, moveDown
		subi  $t4, $t3, 'S'
		beqz  $t4, moveDown
		
		addi  $t0, $t0, -252
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop
		beq   $t5, 0xFF0000, foundedEnemy
		addi  $t0, $t0, -4
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop
		beq   $t5, 0xFF0000, foundedEnemy
		move  $s0, $t0
		sw    $t1, ($t0)
		addi  $t0, $t0, 4
		sw    $t1, ($t0)
		addi  $t0, $t0, 508
		sw    $t2, ($t0)
		addi  $t0, $t0, 4
		sw    $t2, ($t0)
		j     movementLoop
		
	moveDown:
		addi  $t0, $t0, 512
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop
		beq   $t5, 0xFF0000, foundedEnemy
		addi  $t0, $t0, 4
		lw    $t5, ($t0)
		beq   $t5, 0x47475D, movementLoop
		beq   $t5, 0xFF0000, foundedEnemy
		
		sw    $t1, ($t0)
		addi  $t0, $t0, -4
		sw    $t1, ($t0)
		addi  $t0, $t0, -508
		sw    $t2, ($t0)
		addi  $t0, $t0, -4
		sw    $t2, ($t0)
		addi  $t0, $t0, 256
		move  $s0, $t0
		j     movementLoop
		
	doAction:
		j     movementLoop


	
	
	
	
	
	
	
	
	
	
	