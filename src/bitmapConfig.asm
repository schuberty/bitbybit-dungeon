.globl bitmapDisplay_Configuration,genOnlyRoomPar

.data
HPColor:	.word 0xFF0000, 0xD3A4A4
MPColor:	.word 0x000FFF, 0xAAAFFF

.text
bitmapDisplay_Configuration:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)
	
	jal   gen_Background
genOnlyRoomPar:
	jal   gen_Room
	jal   gen_En
	
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra

#########################################################
# Gera o background inicial no Bitmap Display		#
gen_Background:				#
	li    $t0, 0x10040000		# Buffer para preencher fundo
	li    $t2, 3			# Divisor do random int
	li    $t4, 0			# Valor zerado
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
	j     bgNext
bgColor1:
	sw    $t6, ($t0)
	j     bgNext
bgColor2:
	sw    $t7, ($t0)
bgNext:
	add   $t0, $t0, 4		# Incrementa o buffer
	add   $t4, $t4, 1		# Incrementa para o proximo pixel
	blt   $t4, 2076, bgLoop		# Checa se preencheu toda a area do mapa
	jr    $ra
#########################################################
# Gera o chão e as paredas da sala			#
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
gen_En:
	li    $t0, 4
EnLoop1:
	li    $v0, 41
	syscall
	div   $a0, $t0
	mfhi  $a0
	ble   $a0, 1, EnLoop1
	addi  $t0, $t0, 1
	move  $t0, $t1
	li    $t2, 0xFF0000	# En color
	lui   $t3, 0x1004
	addi  $t3, $t3, 1336
	move  $t4, $t3		# Posição principal EN
	li    $t5, 3
EnLoop2:
	li    $t6, 3
EnLoop3:
	sw    $t2, ($t3)
	add   $t3, $t3, 4
	add   $t6, $t6, -1
	bnez  $t6, EnLoop3
	add   $t3, $t3, 244
	add   $t5, $t5, -1
	bnez  $t5, EnLoop2
	
	
	jr    $ra
	

		
