########################################################
# Conectar Bitmap Display tendo a seguinte configuracao:
# Unit width e unit height:...8
# Display width:..............512
# Display height:.............256
# Base address:...............0x1004000(heap)
#
# Configuracoes do MARS:
# Pseudo instructions:........ATIVADO
# Delayed branching:..........DESATIVADO
########################################################
.data
heroName:	.space 64

.text
main:	jal  generateBmBg		# Gera o background inicial do game 
	jal  generateLife		# Gera o desenho inicial dos HP
	jal  generateMana		# Gera o desenho inicial dos MP
	jal  generateRooms		# Gera as salas da dungeon
	j    exit			# Termina a execucao do codigo
	
#########################################
# Gera o background inicial do game	#
generateBmBg:				#
	li   $t0, 0x1004		# Buffer para preencher fundo
	sll  $t0, $t0, 16
	li   $t1, 48			# Numero de pixels preenchidos
	li   $t2, 3			# Divisor do numero random
	li   $t5, 0x452500		# Cores do background
	li   $t6, 0x663E11
	li   $t7, 0x42311F
	li   $v0, 41			# Random int code
genBmLoop:
	syscall	
	div  $a0, $t2			# Escolhe a cor do pixel atual
	mfhi $t3
	beq  $t3, 0, genBm1
	beq  $t3, 1, genBm2
	sw   $t5, ($t0)	
	j    genBmNext1
genBm1:
	sw   $t6, ($t0)
	j    genBmNext1
genBm2:
	sw   $t7, ($t0)
genBmNext1:
	div  $t4, $t1			# Pula caso seja a area do painel
	beqz $t4, genBmNext2
	mfhi $t3
	beqz $t3, genBmIfPanel
	add  $t0, $t0, 4		# Incrementa o buffer
genBmNext2:
	add  $t4, $t4, 1		# Incrementa para o proximo pixel
	blt  $t4, 1537, genBmLoop	# Checa se preencheu toda a area do mapa
	jr   $ra
genBmIfPanel:
	add  $t0, $t0, 68		# Incrementa para a proxima linha por ser a area do painel
	j    genBmNext2			#
#########################################
# Gera o desenho inicial dos HP		#
generateLife:				#
	li   $t0, 0x1004		# Carrega o buffer para desenhar a vida inicial
	sll  $t0, $t0, 16
	add  $t0, $t0, 464
	li   $t1, 0xFF0000		# Cores da vida
	li   $t2, 0xD3A4A4
	li   $t3, 14			# Comeca a desenhar a vida
genManaLoop1:
	sw   $t1, ($t0)
	add  $t0, $t0, 4
	sw   $t1, ($t0)
	add  $t0, $t0, 252
	add  $t3, $t3, -1
	bnez $t3, genManaLoop1
	li   $t3, 6
	add  $t0, $t0, -4
genManaLoop2:
	sw   $t2, ($t0)	
	add  $t0, $t0, 4
	sw   $t1, ($t0)
	add  $t0, $t0, 4
	sw   $t1, ($t0)
	add  $t0, $t0, 4
	sw   $t2, ($t0)
	add  $t0, $t0, 244
	add  $t3, $t3, -1
	bnez $t3, genManaLoop2
	li   $t3, 4
genManaLoop3:
	sw   $t2, ($t0)
	add  $t0, $t0, 4
	add  $t3, $t3, -1
	bnez $t3, genManaLoop3
	jr   $ra
#########################################
# Gera o desenho inicial dos MP		#
generateMana:				#
	li   $t0, 0x1004		# Carrega o buffer para desenhar a mana inicial
	sll  $t0, $t0, 16
	add  $t0, $t0, 488
	li   $t1, 0x000FFF		# Cores da mana
	li   $t2, 0xAAAFFF
	li   $t3, 14			# Comeca a desenhar a mana
genLifeLoop1:
	sw   $t1, ($t0)
	add  $t0, $t0, 4
	sw   $t1, ($t0)
	add  $t0, $t0, 252
	add  $t3, $t3, -1
	bnez $t3, genLifeLoop1
	li   $t3, 6
	add  $t0, $t0, -4
genLifeLoop2:
	sw   $t2, ($t0)
	add  $t0, $t0, 4
	sw   $t1, ($t0)
	add  $t0, $t0, 4
	sw   $t1, ($t0)
	add  $t0, $t0, 4
	sw   $t2, ($t0)
	add  $t0, $t0, 244
	add  $t3, $t3, -1
	bnez $t3, genLifeLoop2
	li   $t3, 4
genLifeLoop3:
	sw   $t2, ($t0)
	add  $t0, $t0, 4
	add  $t3, $t3, -1
	bnez $t3, genLifeLoop3
	jr   $ra
#########################################
# Gera as salas da dungeon		#
generateRooms:				#
	li   $t0, 0			# Numero de salas da dungeon zerado
	li   $t1, 0x1004		# Buffer
	sll  $t1, $t1, 16
	add  $t1, $t1, 776		# Unidade (2,2)
	li   $t2, 0x47475D		# Cores das salas
	li   $t3, 0xB8B06C
	li   $t4, 0xFFFFFF
	li   $v0, 42			# Random int code
	li   $a1, 7
genRmMinRooms:
	syscall				# $t0 = (int)(2 < x < 7)
	blt  $a0, 3, genRmMinRooms
	move $t0, $a0			# Salva $t0
	li   $t5, 8			# Começa a desenhar as salas
genRmLoop1_1:
	sw   $t2, ($t1)
	li   $t6, 8
genRmLoop1_2:
	add  $t1, $t1, 4
	sw   $t3, ($t1)
	add  $t6, $t6, -1
	bnez $t6, genRmLoop1_2
	add  $t1, $t1, 4
	sw   $t2, ($t1)
	add  $t1, $t1, 220
	add  $t5, $t5, -1
	bnez $t5, genRmLoop1_1
	li   $t5, 2
genRmLoop2_1:
	li   $t6, 10
genRmLoop2_2:
	sw   $t2, ($t1)
	add  $t1, $t1, 4
	add  $t6, $t6, -1
	bnez $t6, genRmLoop2_2
	add  $t1, $t1, -2344
	add  $t5, $t5, -1
	bnez $t5, genRmLoop2_1
	jr   $ra
#########################################
# Sai do programa			#
exit:					#
	li   $v0, 10
	syscall				# Fim