#include <cstdio>
#include <iostream>
#include "Vcpu.h"

using namespace std;

#define MEMSIZE 65536

void tick(Vcpu *cpu);

int main(int argc, char **argv) {

	Verilated::commandArgs(argc, argv);

    if (argc < 2) {
        cerr << "usage: " << argv[0] << " <6502 executable>" << endl;
        return 1;
    }

    Vcpu *cpu = new Vcpu;
    char memory[MEMSIZE];
    memset((char *)memory, 9, sizeof(memory));
    int time = 0;
    uint16_t addr = 0;
    uint8_t input;

    /* Read assembled binary into simulated memory */
    char *filename = argv[1];
    FILE *binary = fopen(filename, "r");
    if (binary == NULL) {
        perror(filename);
        return 2;
    }
    size_t len = fread(memory, 1, MEMSIZE, binary);

	printf("%8s,%8s,%8s,%8s\n",
		   "time", "in", "out", "addr");

	while (1) {
		if (Verilated::gotFinish()) { break; }

		addr = cpu->addr;

		if (addr == (len+1)) { break; }

		if (cpu->write) { memory[cpu->addr] = cpu->d_out; }

		input = memory[addr];
		cpu->d_in = input;


		printf("%8d,%8.2x,%8.2x,%8.2x\n",
               time, cpu->d_in, cpu->d_out, cpu->addr);

		tick(cpu);
		time++;
	}
	cpu->final();

	delete cpu;
	return 0;
}

void tick(Vcpu *cpu) {
    cpu->clk = 0;
    cpu->eval();
    cpu->clk = 1;
    cpu->eval();
}
