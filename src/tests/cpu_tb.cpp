#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include "Vcpu.h"

using namespace std;

void tick(Vcpu *cpu);

int main(int argc, char **argv) {

	Verilated::commandArgs(argc, argv);

    if (argc < 2) {
        cerr << "usage: " << argv[0] << " <6502 executable>" << endl;
        return 1;
    }

    Vcpu *cpu = new Vcpu;
    int time = 0;
    unsigned char input;

	/* mmap test program */
	const char *program;
	int fd;
	struct stat sb;
	off_t prog_len;
	off_t pc; // offset into file to read

	fd  = open(argv[1], O_RDONLY);
	fstat(fd, &sb);
	prog_len = sb.st_size;

	program = static_cast<char *>(mmap(NULL, prog_len, PROT_READ, MAP_PRIVATE, fd, 0));
	if (program == MAP_FAILED) exit(1);

	printf("%8s,%8s,%8s,%8s\n",
		   "time", "in", "out", "addr");

	while (1) {
        if (Verilated::gotFinish()) { break; }

		pc = cpu->addr;
		if (pc >= prog_len) break; // for now, break if we read past file

		input = program[pc];
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
