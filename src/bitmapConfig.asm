.globl bitmapDisplay_Configuration,genNextRoom

.data
HPColor:	.word 0xFF0000, 0xD3A4A4
MPColor:	.word 0x000FFF, 0xAAAFFF

.text
bitmapDisplay_Configuration:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)
	
	jal   gen_Background
	lui   $s0, 0x1004				# Bitmap Display address
	addi  $s0, $s0, 4112				# Spawn inicial do player
	genNextRoom:
	jal   gen_Room
	
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra

#########################################################
# Gera o background inicial no Bitmap Display		#
gen_Background:
	lui   $t0, 0x1004				# Buffer para preencher fundo
	li    $t2, 3					# Divisor do random int
	li    $t5, 0x452500				# Cores do background
	li    $t6, 0x663E11
	li    $t7, 0x42311F
	li    $v0, 41					# Random int code
	bgLoop:
		syscall	
		div   $a0, $t2				# Escolhe a cor do pixel atual
		mfhi  $t3				# Resto da divisão que refere-se á cor selecionada
		beq   $t3, 0, bgColor1			# Pula dependendo da cor selecionado
		beq   $t3, 1, bgColor2
		sw    $t5, ($t0)			# Posiciona o pixel no Bitmap Display
		j     bgNext
		bgColor1:
		sw    $t6, ($t0)
		j     bgNext
		bgColor2:
		sw    $t7, ($t0)
		bgNext:
		add   $t0, $t0, 4			# Incrementa o buffer
		add   $t4, $t4, 1			# Incrementa para o proximo pixel
	blt   $t4, 2076, bgLoop				# Checa se preencheu toda a area do mapa
	jr    $ra					# Retorna
#########################################################
# Gera o chão e as paredas da sala			#
gen_Room:
	li    $t0, 0x10040000				# Buffer do Bitmap Display
	add   $t0, $t0, 1032				# Incrementa para inicio da segunda linha da sala
	li    $t1, 0x47475D				# Cor da parede da sala
	li    $t2, 0xB8B06C				# Cor de chão normal
	li    $t3, 0xA59E62				# Cor de chão no escuro
	li    $t4, 8					# Dividor do random int gerado é a probabilidade de ter chão escuro [2,10]
	li    $t6, 25					# Quantidade de linhas para chão entre as paredes laterais
	roomLoop1:
		sw    $t1, ($t0)			# Pixel da primeira parede lateral esquerda
		add   $t0, $t0, 4			# Incrementa para começar á desenhar o chão
		li    $t5, 58				# Contador de pixels do chão
		roomLoop2:
			li    $v0, 41			# Mesmo processo que em gen_Background para gerar o chão
			syscall
			div   $a0, $t4
			mfhi  $a0
			beqz  $a0, roomShadowColor	# Pula para desenhar chão no escuro
			sw    $t2, ($t0)		# Desenha chão com luminosidade
			j    roomNext
			roomShadowColor:
			sw    $t3, ($t0)		# Desenha chão no escuro
			roomNext:
			add   $t0, $t0, 4
			add   $t5, $t5, -1
		bnez  $t5, roomLoop2
		sw    $t1, ($t0)			# Pixel da primeira parede lateral direita
		add   $t0, $t0, 20			# Pula pra próxima linha
		add   $t6, $t6, -1
	bnez  $t6, roomLoop1				# Se não completou todo o chão
	li    $t6, 2					# Quantidade de paredes horizontais
	roomLoop3:
		li    $t5, 60				# Pixels de cada parede horizontal
		roomLoop4:				# Primeiro adiciona a inferior
			sw    $t1, ($t0)
			add   $t5, $t5, -1
			add   $t0, $t0, 4
		bnez  $t5, roomLoop4			# Após terminar a inferior
		add   $t6, $t6, -1
		add   $t0, $t0, -6896			# Decrementa para desenhar a parede superior
	bnez  $t6, roomLoop3				# Se completou as duas paredes horizontais
	jr    $ra					# Retorna
#########################################################
# Gera os inimigos na sala atual			#

