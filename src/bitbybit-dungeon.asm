.globl main,stop

.data

.text
main:
	jal  start
	jal  bitmapDisplay_Configuration
	jal  stop
###########################################
stop:
	li   $v0, 17
	syscall