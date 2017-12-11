/*
 * hal.h
 *
 * Created: 11/6/2017 10:59:53 AM
 *  Author: Octav & Nikolai & Mihai
 */ 

 extern void hal_create();
 extern void hal_set_led(uint8_t led_no, uint8_t state);
 extern uint8_t hal_is_pressed(uint8_t key_no);
 extern uint16_t hal_get_adc_value();