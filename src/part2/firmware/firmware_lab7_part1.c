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
#define LOOP_WAIT_LIMIT 100

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

	// The stack in an infinite loop that does nothing
	while (1) 
	{}
}