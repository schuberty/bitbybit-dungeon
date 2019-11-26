.globl bitmapDisplay_Configuration

.data
HPColor:	.word 0xFF0000, 0xD3A4A4
MPColor:	.word 0x000FFF, 0xAAAFFF

.text
bitmapDisplay_Configuration:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)
	
	jal   gen_Background
	jal   gen_HealthPoints
	jal   gen_ManaPoints2
	jal   gen_Room
	
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra

#########################################
# Gera o background inicial		#
gen_Background:				#
	li    $t0, 0x10040000		# Buffer para preencher fundo
	li    $t1, 48			# Numero de pixels preenchidos
	li    $t2, 3			# Divisor do random int
	li    $t5, 0x452500		# Cores do background
	li    $t6, 0x663E11
	li    $t7, 0x42311F
	li    $v0, 41			# Random int code
bgLoop:
	syscall	
	div   $a0, $t2			# Escolhe a cor do pixel atual
	mfhi  $t3
	beq   $t3, 0, bgColor1
	beq   $t3, 1, bgColor2
	sw    $t5, ($t0)	
	j     bgNext1
bgColor1:
	sw    $t6, ($t0)
	j     bgNext1
bgColor2:
	sw    $t7, ($t0)
bgNext1:
	div   $t4, $t1			# Pula caso seja a area do painel
	beqz  $t4, bgNext2
	mfhi  $t3
	beqz  $t3, bgSkipStatus
	add   $t0, $t0, 4		# Incrementa o buffer
bgNext2:
	add   $t4, $t4, 1		# Incrementa para o proximo pixel
	blt   $t4, 1537, bgLoop		# Checa se preencheu toda a area do mapa
	jr    $ra
bgSkipStatus:
	add   $t0, $t0, 68		# Incrementa para a proxima linha por ser a area dos status
	j     bgNext2			#
#########################################
# Gera o desenho inicial dos HP		#
gen_HealthPoints:			#
	li    $t0, 0x10040000		# Carrega o buffer para desenhar a vida inicial
	add   $t0, $t0, 464
	li    $t1, 0xFF0000		# Cores da vida
	li    $t2, 0xD3A4A4
	li    $t3, 14			# Comeca a desenhar a vida
HPLoop1:
	sw    $t1, ($t0)
	add   $t0, $t0, 4
	sw    $t1, ($t0)
	add   $t0, $t0, 252
	add   $t3, $t3, -1
	bnez  $t3, HPLoop1
	li    $t3, 6
	add   $t0, $t0, -4
HPLoop2:
	sw    $t2, ($t0)	
	add   $t0, $t0, 4
	sw    $t1, ($t0)
	add   $t0, $t0, 4
	sw    $t1, ($t0)
	add   $t0, $t0, 4
	sw    $t2, ($t0)
	add   $t0, $t0, 244
	add   $t3, $t3, -1
	bnez  $t3, HPLoop2
	li    $t3, 4
HPLoop3:
	sw    $t2, ($t0)
	add   $t0, $t0, 4
	add   $t3, $t3, -1
	bnez  $t3, HPLoop3
	jr    $ra
#########################################
# Gera o desenho inicial dos MP		#
gen_ManaPoints:
	jr    $ra
#########################################
# Gera o desenho inicial dos MP		#
gen_ManaPoints2:			#
	li    $t0, 0x10040000		# Carrega o buffer para desenhar a mana inicial
	add   $t0, $t0, 488
	li    $t1, 0x000FFF		# Cores da mana
	li    $t2, 0xAAAFFF
	li    $t3, 14			# Comeca a desenhar a mana
MPLoop1:
	sw    $t1, ($t0)
	add   $t0, $t0, 4
	sw    $t1, ($t0)
	add   $t0, $t0, 252
	add   $t3, $t3, -1
	bnez  $t3, MPLoop1
	li    $t3, 6
	add   $t0, $t0, -4
MPLoop2:
	sw    $t2, ($t0)
	add   $t0, $t0, 4
	sw    $t1, ($t0)
	add   $t0, $t0, 4
	sw    $t1, ($t0)
	add   $t0, $t0, 4
	sw    $t2, ($t0)
	add   $t0, $t0, 244
	add   $t3, $t3, -1
	bnez  $t3, MPLoop2
	li    $t3, 4
MPLoop3:
	sw    $t2, ($t0)
	add   $t0, $t0, 4
	add   $t3, $t3, -1
	bnez  $t3, MPLoop3
	jr    $ra
#########################################
# Gera a sala da dungeon		#
gen_Room:				#
	li    $t0, 0x10040000		# Buffer
	add   $t0, $t0, 1032
	li    $t1, 0x47475D		# Cores das salas
	li    $t2, 0xB8B06C
	li    $t3, 0xA59E62
	li    $t4, 2			# Dividor do random int gerado
	li    $t6, 25			
roomLoop1:
	sw    $t1, ($t0)
	add   $t0, $t0, 4
	li    $t5, 42
roomLoop2:
	li    $v0, 41			# Random int code
	syscall
	div   $a0, $t4
	mfhi  $a0
	beqz  $a0, roomColor2
	sw    $t2, ($t0)
	j    roomNext
roomColor2:
	sw    $t3, ($t0)
roomNext:
	add   $t0, $t0, 4
	add   $t5, $t5, -1
	bnez  $t5, roomLoop2
	sw    $t1, ($t0)
	add   $t0, $t0, 84
	add   $t6, $t6, -1
	bnez  $t6, roomLoop1
	li    $t6, 2
roomLoop3:
	li    $t5, 44
roomLoop4:
	sw    $t1, ($t0)
	add   $t5, $t5, -1
	add   $t0, $t0, 4
	bnez  $t5, roomLoop4
	add   $t6, $t6, -1
	add   $t0, $t0, -6832
	bnez  $t6, roomLoop3
	jr    $ra
#########################################
# 					#