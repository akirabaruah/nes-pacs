#include <cassert>
#include "Vregister.h"

int main(int argc, char **argv) {
	Verilated::commandArgs(argc, argv);
	Vregister *r = new Vregister;
	int time;

	printf("%8s,%8s,%8s,%8s,%8s,%8s\n",
		   "time", "clk", "reset", "load", "in", "out");

	// Timestepping loop
	for (time = 0; time <= 50; time++) {
		if (Verilated::gotFinish()) { break; }
		if (time % 5 == 0) { r->clk = !r->clk; }

		switch (time) {
		case 0:
			r->clk = 0;
			r->reset = 1;
			r->load = 0;
			r->in = 0x2a;
			break;
		case 3:
			r->reset = 0;
			r->load = 1;
			break;
		case 13:
			r->load = 0;
			r->in = 0x7b;
			break;
		case 23:
			r->reset = 1;
			break;
		case 33:
			r->reset = 0;
			break;
		case 43:
			r->load = 1;
			break;
		default:
			if (time % 5) { continue; }
		}

		r->eval();
		printf("%8d,%8x,%8x,%8x,%8.2x,%8.2x\n",
			   time, r->clk, r->reset, r->load, r->in, r->out);
		assert(r->out == r->out);
	}
	r->final();

	// Cleanup
	delete r;
	return 0;
}
