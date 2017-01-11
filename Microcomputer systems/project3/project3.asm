.include "m16def.inc"	
.org 0
.cseg
.def programm=r18
.def proplysh=r19
.def stragisma=r20
.def delay_counter=r30
.def door=r21
.def alluse_counter = r24
sp_init:     
	ldi r16,low(RAMEND)            ;arxikopoihsh stack pointer
	out spl,r16
	ldi r16,high(RAMEND)
	out sph,r16
switch_init:
	clr r17
	out DDRD,r17
	ser r17				           ;arxikopoihsh switch
	out PIND,r17
led_init:
	ser r17				           ;arxikopoihsh led
	out DDRB,r17
	ser r17
	out PORTB,r17
	ldi r17,0b10000000
	com r17
	out PORTB,r17
	clr programm
	clr proplysh
	clr delay_counter
	clr r28
	clr r20
	clr alluse_counter
	

select_programm:
	sbis PIND,0x03
	ori programm,0b00000001
	sbis PIND,0x04
	ori programm,0b00000010
	sbis PIND,0x05
	ori programm,0b00000100
	
	sbis PIND,0x02
	ldi proplysh,1
	
	sbis PIND,0x06
	rjmp define_programm

	rjmp select_programm

	
define_programm:
	
	cpse programm,r28
	brne jump0
	ldi delay_counter,8
	ldi stragisma,1
	jump0:
	adiw r28,1
	cpse programm,r28
	brne jump1
	ldi delay_counter,16
	ldi stragisma,1
	jump1:
	adiw r28,1
	cpse programm,r28
	brne jump2
	ldi delay_counter,32
	ldi stragisma,1
	jump2:
	adiw r28,1
	cpse programm,r28
	brne jump3
	ldi delay_counter,64
	ldi stragisma,1
	jump3:
	adiw r28,1



	cpse programm,r28
	brne jump4
	ldi delay_counter,8
	jump4:
	adiw r28,1
	cpse programm,r28
	brne jump5
	ldi delay_counter,12
	jump5:
	adiw r28,1
	cpse programm,r28
	brne jump6
	ldi delay_counter,32
	jump6:
	adiw r28,1
	cpse programm,r28
	brne jump7
	ldi delay_counter,64
	jump7:
	

	com r17
	ori r17,0b00000011
	com r17

	ldi r28,0

	cpi proplysh,1
	breq proplysh_led

	rjmp change


proplysh_led:
	com r17
	ori r17,0b00000100
	com r17
	out PORTB,r17




proplysh_wash:
	sbis PIND,0x00
	rcall door_led_off_on
	sbis PIND,0x00
	rjmp proplysh_wash


	sbis PIND,0x07
	rcall water_stop
	

	mov r22,alluse_counter
	sbis PIND,0x01
	rcall overloaded

	rcall delay05s
	adiw alluse_counter,1
	
	cpi alluse_counter,8
	breq change

	rjmp proplysh_wash

door_led_off_on:
	com r17
	andi r17,0b11111110
	com r17
	out PORTB,r17

	rcall delay05s
	
	com r17
	ori r17,0b00000001
	com r17
	out PORTB,r17


	ret

water_stop:
	com r17
	ori r17,0b01000000
	com r17
	out PORTB,r17
	
	water_stop_on_off:
		com r17
		ori r17,0b00000010
		com r17
		out PORTB,r17
	
		rcall delay05s
			
		com r17
		andi r17,0b11111101
		com r17
		out PORTB,r17

		sbis PIND,0x07
		rjmp water_stop_on_off
	
	ret


change:
	com r17
	andi r17,0b11111011
	ori r17,0b00001000
	com r17
	out PORTB,r17

wash:
	sbis PIND,0x00
	rcall door_led_off_on
	sbis PIND,0x00
	rjmp wash

	sbis PIND,0x07
	rcall water_stop

	mov r22,delay_counter
	sbis PIND,0x01
	rcall overloaded
	
	rcall delay05s
	subi delay_counter,1
	
	cpi delay_counter,0
	breq change2

	rjmp wash


overloaded:
	mov r28,r22
	lsr r28
	lsl r28


	cpse r22,r28
	rjmp avoid0
	com r17
	ori r17,0b00000010
	com r17
	out PORTB,r17
	rjmp avoid1
	

	avoid0:
	com r17
	andi r17,0b11111101
	com r17
	out PORTB,r17
	avoid1:

	ret


change2:
	com r17
	andi r17,0b11110111
	ori r17, 0b00010000
	com r17
	out PORTB,r17
	ldi alluse_counter,0
	rjmp ksebgalma

ksebgalma:
	sbis PIND,0x00
	rcall door_led_off_on
	sbis PIND,0x00
	rjmp ksebgalma

	sbis PIND,0x07
	rcall water_stop
	
	mov r22,alluse_counter
	sbis PIND,0x01
	rcall overloaded

	rcall delay05s
	adiw alluse_counter,1
	
	cpi alluse_counter,2
	breq change3

	rjmp ksebgalma




change3:
	cpi stragisma,0
	breq exit
	com r17
	andi r17,0b11100111
	ori r17, 0b00100000
	com r17
	out PORTB,r17
	ldi alluse_counter,0
	rjmp stragisma_wash


stragisma_wash:
	sbis PIND,0x00
	rcall door_led_off_on
	sbis PIND,0x00
	rjmp stragisma_wash

	sbis PIND,0x07
	rcall water_stop

	mov r22,alluse_counter
	sbis PIND,0x01
	rcall overloaded
	
	rcall delay05s
	adiw alluse_counter,1
	
	cpi alluse_counter,4
	breq exit

	rjmp stragisma_wash



exit:
	rjmp exit




bdelay05s:
	ret

delay05s:
	ldi  r21, 11
    ldi  r23, 38
    ldi  r25, 94
L1: dec  r25
    brne L1
    dec  r23
    brne L1
    dec  r21
    brne L1
   	ret



