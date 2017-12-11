
/*
 * hal.S
 *
 * Created: 11/6/2017 10:50:13 AM
 *  Author: Octav & Nikolai & Mihai
 */ 
 #include <avr/io.h>

 #define temp R16
 #define to_io_addr(addr) (addr-0x20)
 
 
.global hal_create
.global hal_set_led
.global hal_is_pressed
.global hal_get_adc_value

// config: 1) temp sensor 2) output and input ports for leds and switches 

hal_create:
	// setting values for ADC registers
	ldi temp, 0x80
	sts ADMUX, temp
	ldi temp, 0x86
	sts ADCSRA, temp

	// setting leds
	ldi temp, 0xFF
	out to_io_addr(DDRB), temp
	// turn off leds initially
	out to_io_addr(PORTB), temp
	
	// setting switches
	ldi temp, 0x00
	out to_io_addr(DDRA), temp
	ret


 #define param1 r24
 #define param2 r22 
 #define mask r16 // used by gcc - remember to save
 #define port_value r17 // used by gcc - remember to save

// TURN ON/OFF A LED
hal_set_led:
	push r16
	push r17
	ldi mask, 1 ; initial mask value
led_change_shift:
	cpi param1, 0 ; left shifting the number
	breq led_change ; of times given by the
	dec param1 ; input parameter
	lsl mask
	rjmp led_change_shift
led_change:
	in port_value, to_io_addr(PORTB) ; instead of PORTB-0x20
	
	//TURN LED ON or OFF?
	cpi param2, 0
	breq led_off_done

	//TURN LED ON
	com port_value
	or port_value, mask
	com port_value
	rjmp led_finish
led_off_done:
	or port_value, mask
led_finish:	
	out to_io_addr(PORTB), port_value
	pop r17
	pop r16
	ret

// CHECK WHETHER THE SPECIFIC SWITCH IS PRESSED
hal_is_pressed:
	// SAVING WORKING REGISTER
	push r16
	push r17
	ldi mask, 1 ; initial mask value
sw_shift:
	cpi param1, 0 ; left shifting the number
	breq sw_check ; of times given by the
	dec param1 ; input parameter
	lsl mask
	rjmp sw_shift
sw_check:
	in port_value, to_io_addr(PINA) ; 
	com port_value
	and port_value, mask

	clr r25
	mov r24, port_value

	pop r17
	pop r16

	ret 


//SUBROUTINE TO GET VALUE FROM SENSOR
hal_get_adc_value:
	//SAVE WORKING REGISTERS
	push r16
	push r17
	clr r16
	clr r17
	//LOAT ADSC BIT INTO ADCRA 
	ldi r16, 0b01000000
	lds r17, ADCSRA 
	or  r17, R16
	sts ADCSRA, R17
	//WAIT TO FETCH RESUTLS
	WAIT_TO_DELIVER_RESUTLS:
	lds r17, ADCSRA
	ldi r16, 0b01000000
	and r16, r17
	cpi r16, 0b00000000
	brne GRAB_RESULT
	rjmp WAIT_TO_DELIVER_RESUTLS
	GRAB_RESULT:
	//READ VALUE FROM SENSOR
	lds r24, ADCL
	lds r25, ADCH
	//RESTORE WORKING REGISTERS
	pop r17
	pop r16
	ret
