#ifndef __FAKE6502_H
#define __FAKE6502_H

#include <stdint.h>

/* User defined functions */
extern uint8_t read6502(uint16_t address);
extern void write6502(uint16_t address, uint8_t value);

/* Useful functions */
void reset6502();
void exec6502(uint32_t tickcount);
void step6502();
void irq6502();
void nmi6502();
void hookexternal(void *funcptr);

/* Internal state variables */
extern uint32_t clockticks6502;
extern uint32_t instructions;
extern uint16_t pc;
extern uint8_t sp, a, x, y, status;
extern uint8_t opcode;

#endif
