/*
	Modified by Jorge Munoz Taylor
	A53863
	IE0424
	University of Costa Rica
	II-2020
*/

#include <stdint.h>

#define LED_REGISTERS_MEMORY_ADD 0x10000000
#define IRQ_REGISTERS_MEMORY_ADD 0x10000004
#define READ_ACCELEROMETER_Y     0x20000000
#define READ_ACCELEROMETER_Z     0x30000000
#define LOOP_WAIT_LIMIT 20000

uint32_t global_counter = 0;

static void putuint(uint32_t i) {
	*((volatile uint32_t *)LED_REGISTERS_MEMORY_ADD) = i;
}

static void putuint2(uint32_t i) {
	*((volatile uint32_t *)IRQ_REGISTERS_MEMORY_ADD) = i;
}


uint32_t *irq(uint32_t *regs, uint32_t irqs) {
    global_counter += 1;
    putuint2(global_counter);
    return regs;
}




void main() {

	uint32_t y_value;
	uint32_t z_value;
	uint32_t final_value;
	int delay;

	// 
	while (1) 
	{
		y_value = *((volatile uint32_t *)READ_ACCELEROMETER_Y);
		y_value = y_value << 16;

		z_value = *((volatile uint32_t *)READ_ACCELEROMETER_Z);
		
		final_value = y_value | z_value;

		putuint ( final_value );

		delay = 0;
		while (delay < LOOP_WAIT_LIMIT)
		{
			delay++;
		}
	}
}