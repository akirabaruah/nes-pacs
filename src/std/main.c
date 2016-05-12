#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "fake6502.h"

#define MEMSIZE 65536

uint8_t memory[MEMSIZE];

uint8_t read6502(uint16_t address) {
    return memory[address];
}

void write6502(uint16_t address, uint8_t value) {
    memory[address] = value;
}

void print_stats(void) {
    static int first = 1;
    if (first) {
        printf("Cycle Op  A  X  Y  P\n");
        first = 0;
    }
    printf("%5d %.2x %.2x %.2x %.2x %.2x\n",
           clockticks6502, opcode, a, x, y, status);
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
    memset(memory, 9, MEMSIZE);
    while(fread(&byte, sizeof(byte), 1, file)) {
        memory[i++] = byte;
    }
    memory[i] = 0;
    memory[0xFFFC] = 0;
    memory[0xFFFD] = 0;

    /* Start simulation */
    reset6502();
    print_stats();
    while ((status & 0x04) == 0) {
        step6502();
        print_stats();
    }

    return 0;
}
