/*
 * CALAssignment4.c
 *
 * Created: 11/6/2017 10:40:43 AM
 * Author : Octav & Nikolai & Mihai
 */ 
#define F_CPU 10000000L

#include <avr/io.h>
#include <stdio.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "atmega2560_drivers.h"
#include "hal.h"


int main(void)
{
	init_stdio(0, 10000000L);
	hal_create();
	sei();
	
    while (1) 
    {
		uint16_t adc_value = hal_get_adc_value();
		float mili_voltage = ((adc_value * 1.1) / 1024) * 1000;
		float temperature = mili_voltage / 20;
		send_to_leds(temperature);
		
		
		if (is_logging_on()) {
			printf("Temperature: %.1f\r", temperature);
		}
		
		_delay_ms(200);
    }
}

int IS_LOG_ON = 1;

int is_logging_on(){
	if (hal_is_pressed(0))
		IS_LOG_ON = 1;
	else if (hal_is_pressed(1))
		IS_LOG_ON = 0;
	
	return IS_LOG_ON;
}

void send_to_leds(float temperature) {
	// check if value is rounded
	int leds_to_turn_on = (temperature - 20) / 2.5;
	// turn on necessary led
	for (int i = 0; i <= leds_to_turn_on; i++) {
		hal_set_led(i, 1);
	} 		
	// turn off other led
	for (int i = leds_to_turn_on + 1; i <= 7; i++) {
		hal_set_led(i, 0);
	}
}

