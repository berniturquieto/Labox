;
; servingui.asm
;
; Created: 30/5/2018 11:21:53
; Author : berna
;



.include "avr_macros.inc"


.dseg
	.def	AUX		=	R16
	.def	PWML	=	R30
	.def	PWMH	=	R31



.cseg
	.org INT_VECTORS_SIZE
	LDI r16,HIGH(RAMEND)	;Inicializo Stack Pointer
	OUT SPh, r16
	LDI r16, LOW(RAMEND)
	OUT SPl, r16
	rjmp main

main:

	sbi DDRB,6 ; Pongo como salida el pin OC1B por donde va a salir la señal del PWM
	call configure_pwm
LOOP:
	call delay_1s
	ldi PWML,LOW(4000)
	ldi PWMH,HIGH(4000)
	call set_pwm
	call delay_1s
	ldi PWMH, HIGH(1000)
	ldi PWML, LOW(1000) ; Inicio el ancho de pulso en 1ms
	call set_pwm 	;A esta funcion se la llama cada vez que se quiera modificar el ancho de pulso
	RJMP LOOP

;Funcion de prueba para el servo, MUY probablemente tenga errores con los delays
; porque el servo no funciona bien. 
/*variar_pwm: ; varia el ancho de pulso entre 1 y 2ms yendo para adelante y para atras
	ldi PWMH, HIGH(4000)
	ldi PWML, LOW(4000)
comparar:
	cpi PWMH,HIGH (2000)
	brne atras
	cpi PWML, LOW(2000)
	brne atras
	rjmp volver
atras:
	output OCR1BH,PWMH
	output OCR1BL,PWML
	call delay_300us
	sbiw PWMH:PWML,1
	rjmp comparar
volver:
	cpi PWMH,HIGH (4000)
	brne adelante
	cpi PWML, LOW(4000)
	brne adelante
	rjmp comparar

adelante:
	output OCR1BH,PWMH
	output OCR1BL,PWML
	call delay_300us
	adiw PWMH:PWML,1
	rjmp volver

delay_300us:
    ldi  r18, 7
    ldi  r19, 59
L1: dec  r19
    brne L1
    dec  r18
    brne L1

	ret
*/

delay_1s:
    ldi  r18, 3
    ldi  r19, 44
    ldi  r20, 82
L2: dec  r18
    brne L2
    dec  r19
    brne L2
    dec  r20
    brne L2
	ret


		
configure_pwm: ; Primero seteo el T/C para que se resetee cada 20ms y que hasta que encuentre OCR1B este en 1 (Ancho de pulso variable para el servo)

	; Fast PWM (WGM[3:0] = 15) y en modo non-inverting para el registro OC1B, lo limpia cuando matchea y lo setea de vuelta en BOTTOM
	
	input AUX,TCCR1A
	ori AUX,(1<<COM1B1)|(1<<WGM11)|(1<<WGM10) ; Set en modo non-inverting, WGM11 y WGM10 en 1 para setear el modo Fast PWM
	output TCCR1A,AUX

	input AUX,TCCR1B
	ori AUX,(1<<WGM13)|(1<<WGM12) ; Set en modo Fast PWM, el contador se resetea cuando llega a OCR1A
	ori AUX, (1<<CS11) ; Set prescaler en 8
	output TCCR1B,AUX

	; Poniendo el prescaler en 8, y con una frecuencia de 16MHz,contar hasta 40000 tarda 20ms
  ; 40000/(16Mega/8) = 0.02
	ldi PWMH, HIGH (40000)
	ldi PWML, LOW (40000) 
	output OCR1AH,PWMH
	output OCR1AL,PWML

	ldi PWMH, HIGH(2000)
	ldi PWML, LOW(2000) ; Inicio el ancho de pulso en 1ms
	call set_pwm 	;A esta funcion se la llama cada vez que se quiera modificar el ancho de pulso
	ret
  
  
  set_pwm: ; El registro OCR1B es el que determina el ancho de pulso. Con esta funcion actualizo ese registro con lo que hay en PWMH/L
	  output OCR1BH,PWMH
	  output OCR1BL,PWML
	  ret
