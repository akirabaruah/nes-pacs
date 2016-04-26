#include <stdint.h>
#include <stdio.h>
#include "fake6502.h"

#define MEMSIZE 65536

uint8_t memory[MEMSIZE];

uint8_t read6502(uint16_t address) {
    return memory[address];
}

void write6502(uint16_t address, uint8_t value) {
    memory[address] = value;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("usage: %s <6502 binary>\n", argv[0]);
        return 1;
    }

    char *filename = argv[1];
    uint8_t byte;
    FILE *file = fopen(filename, "r");
    if (!file) {
        perror(filename);
        return 2;
    }
    int i = 0;
    while(fread(&byte, sizeof(byte), 1, file)) {
        memory[i++] = byte;
    }

    /* Start simulation */
    reset6502();
    printf("Op:%.2x Cycle:%3d PC:%.2x A:%.2x X:%.2x Y:%.2x P:%.2x\n",
           opcode, clockticks6502, pc, a, x, y, status);
    while ((status & 0x04) == 0) {
        step6502();
        printf("Op:%.2x Cycle:%3d PC:%.2x A:%.2x X:%.2x Y:%.2x P:%.2x\n",
               opcode, clockticks6502, pc, a, x, y, status);
    }

    return 0;
}
