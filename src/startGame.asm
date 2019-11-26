.globl start_Game

.data

.text
start_Game:
	addiu $sp, $sp, -4
	sw    $ra, ($sp)
	
	
	
	lw    $ra, ($sp)
	addiu $sp, $sp, 4
	jr    $ra