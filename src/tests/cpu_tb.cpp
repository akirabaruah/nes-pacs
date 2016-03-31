#include <cstdio>
#include <cstdlib>
#include <iostream>
#include "Vcpu.h"

using namespace std;

void tick(Vcpu *cpu);

int main(int argc, char **argv) {
	Verilated::commandArgs(argc, argv);

    if (argc < 2) {
        cerr << "usage: " << argv[0] << endl;
        return 1;
    }

    Vcpu *cpu = new Vcpu;
    FILE *program = fopen(argv[1], "rb");
    int time = 0;
    unsigned char input;

	printf("%8s,%8s,%8s,%8s\n",
		   "time", "in", "out", "addr");

    while (fread(&input, 1, 1, program)) {
        if (Verilated::gotFinish()) { break; }

        cpu->d_in = input;
        printf("%8d,%8.2x,%8.2x,%8.2x\n",
               time, input, cpu->d_out, cpu->addr);
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
