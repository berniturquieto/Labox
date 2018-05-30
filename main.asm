;
; mazidi.asm
;
; Created: 16/5/2018 20:13:31
; Author : berna
;


; Replace with your application code

.equ baudrate = 103
.include "M2560def.inc" 
INICIO:
	LDI r16,HIGH(RAMEND)	;Inicializo Stack Pointer
	OUT SPh, r16
	LDI r16, LOW(RAMEND)
	OUT SPl, r16
	
	call USART_Init			;Función que inicializa los registros para USART

aca:

	INC R16
	call USART_Transmit
	rjmp aca


USART_Init:
;Setting the baud rate, setting frame format and enabling the Transmitter or the
;Receiver depending on the usage.
	push r16
	push r17

	ldi r16, LOW(baudrate)		;Baud rate = 9600 (8 MHz, System clock)
	ldi r17, HIGH(baudrate)		;Baud rate = 9600
	; Set baud rate to UBRR0
	sts UBRR0H, r17		;utilizo STS en vez de OUT, ya que las direcciones estan en "extended I/O"
	sts UBRR0L, r16

	; Enable receiver and transmitter
	ldi r16, (1<<RXEN0)|(1<<TXEN0)
	sts UCSR0B, r16

	; Set frame format: 8data, 1stop bit
	ldi r16, (0<<USBS0)|(3<<UCSZ00)
	sts UCSR0C, r16

	pop r17
	pop r16
	RET

USART_Transmit:
;	 r16	;Data
	push r17	;Flags check
	

check_transmit_buffer_empty:
	; Wait for empty transmit buffer
	lds r17, UCSR0A
	sbrs r17, UDRE0
	rjmp check_transmit_buffer_empty

	; Put data (r16) into buffer, sends the data
	sts UDR0,r16	;Dato cargado antes de la función

	pop r17
	RET