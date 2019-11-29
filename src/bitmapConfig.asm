.globl bitmapDisplay_Configuration,genNextRoom,nextRoom

.data
actualRmColor:	.word 0xFFF93F
endedRmColor:	.word 0x53FF3F
.text
bitmapDisplay_Configuration:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)
	
	jal   gen_Background
	lui   $s0, 0x1004				# Bitmap Display address
	addi  $s0, $s0, 4112				# Spawn inicial do player
	jal   gen_Map
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
# Gera o mapa no topo do Bitmap Display			#
gen_Map:
	lui   $t0, 0x1004
	addi  $t0, $t0, 272				# Base address
	li    $t3, 2					# Numero de linhas que haveram o mapa
	lw    $t7, actualRmColor			# Cor da sala atual
	li    $t8, 0xFF0000				# Cor da sala final
	li    $t9, 0xFF7165				# Cor de salas seguintes

	mapLoop1:
		sw    $t7, ($t0)			# Desenha a sala atual inicial
		sw    $t7, 4($t0)
		li    $t2, 17
		mapLoop2:
			add   $t0, $t0, 12		# Desenha as salas intermediarias
			sw    $t9, ($t0)
			sw    $t9, 4($t0)
			add   $t2, $t2, -1
		bnez  $t2, mapLoop2
		add   $t0, $t0, 12			# Desenha a sala final
		sw    $t8, ($t0)
		sw    $t8, 4($t0)
		add   $t3, $t3, -1
		add   $t0, $t0, 40			# Incrementa para a proxima linha
	bnez  $t3, mapLoop1				# Se não for a ultima linha
	jr    $ra					# Retorna
#########################################################
# Gera o chão e as paredas da sala			#
gen_Room:
	lui    $t0, 0x1004				# Buffer do Bitmap Display
	add   $t0, $t0, 1288				# Incrementa para inicio da segunda linha da sala
	li    $t1, 0x47475D				# Cor da parede da sala
	li    $t2, 0xB8B06C				# Cor de chão normal
	li    $t3, 0xA59E62				# Cor de chão no escuro
	li    $t4, 8					# Dividor do random int gerado é a probabilidade de ter chão escuro [2,10]
	li    $t6, 24					# Quantidade de linhas para chão entre as paredes laterais
	roomLoop1:
		sw    $t1, ($t0)			# Pixel da primeira parede lateral esquerda
		add   $t0, $t0, 4			# Incrementa para começar á desenhar o chão
		li    $t5, 58				# Contador de pixels do chão
		roomLoop2:
			li    $v0, 41			# Mesmo processo que em gen_Background para gerar o chão
			syscall
			div   $a0, $t4
			mfhi  $a0
			beqz  $a0, roomShadowColor	# Pula para desenhar chão com sombra
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
		add   $t0, $t0, -6640			# Decrementa para desenhar a parede superior
	bnez  $t6, roomLoop3				# Se completou as duas paredes horizontais
	jr    $ra					# Retorna
#-------#################################################
	# -Atualiza dados e o mapa para a próxima sala	#
	nextRoom:
	lui    $t0, 0x1004				# Buffer do Bitmap Display
	add   $t0, $t0, 260				# Incrementa para 12 bits antes da primeira unidade da primeira sala
	lw    $t1, gameSettings+4			# Sala atual
	mul   $t1, $t1, 12				# Multiplica para pegar o endereço da sala atual
	add   $t0, $t0, $t1				# Adiciona ao buffer para selecionar a sala atual
	lw    $t8, actualRmColor			# Cor de sala atual
	lw    $t9, endedRmColor				# Cor de sala completada
	sw    $t9, ($t0)				# Começa a desenhar a sala completada
	sw    $t9, 4($t0)
	sw    $t9, 256($t0)
	sw    $t9, 260($t0)
	add   $t0, $t0, 12
	sw    $t8, ($t0)				# Começa a desenhar a sala atual
	sw    $t8, 4($t0)
	sw    $t8, 256($t0)
	sw    $t8, 260($t0)
	lw    $t1, gameSettings+4
	add   $t1, $t1, 1
	sw    $t1, gameSettings+4
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	jr    $ra
	
	
	
	
	
