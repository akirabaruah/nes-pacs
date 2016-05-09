module nes (
	input logic clk,
	input logic reset,

	input logic chipselect,

	input logic read,	
	output logic [7:0] readdata,

	input logic write,
	input logic [15:0] writedata,
	input logic [15:0] address
);

logic zero = 0;
logic one = 1;
logic sync;
logic cpu_write, mem_write;
logic [15:0] cpu_addr, mem_addr;
logic [7:0] d_in, d_out, mem_in, mem_out;


logic [7:0] nes_op = writedata[15:8];

if (writing to memory a binary)
	memory.address = ?
	memory.write = writedata[7:0];
if stop
if start

cpu c (
	.clk (clk),
	.reset (reset),
   .ready (one),
   .irq (zero),
   .nmi (zero),
 
   .d_in(d_in),
   .write(cpu_write),

   .sync(sync),

   .d_out(d_out),
   .addr(cpu_addr)
);

memory mem (
	.clk (clk),
	.addr(mem_addr),
	.write(mem_write),
	.in(mem_in),
	.out(mem_out)
);

always_ff @(posedge clk) begin



end


endmodule
