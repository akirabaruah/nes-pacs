#include <cstdio>
#include <iostream>
#include "Vcpu.h"

using namespace std;

#define MEMSIZE 65536

void tick(Vcpu *cpu);
void print_stats(Vcpu *cpu, int time);

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

	while (1) {
		if (Verilated::gotFinish()) { break; }

		addr = cpu->addr;

		if (addr == (len+1)) { break; }

		if (cpu->write) { memory[cpu->addr] = cpu->d_out; }

		tick(cpu);

		input = memory[addr];
		cpu->d_in = input;

        print_stats(cpu, time);
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

void print_stats(Vcpu *cpu, int time) {
    static int first = 1;
    if (first) {
        printf("Cycle Op  A\n");//  X  Y  P\n");
        first = 0;
    }

    if (cpu->sync) {
        printf("%5d %.2x %.2x\n",// %.2x %.2x %.2x\n",
               time,
               cpu->v__DOT__IR,
               cpu->v__DOT__A);/*,
               cpu->v__DOT__X,
               cpu->v__DOT__Y,
               cpu->v__DOT__P);*/
    }
}
