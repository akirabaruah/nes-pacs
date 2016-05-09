module nes (
	input logic clk,
	input logic reset,

	input logic chipselect,

	input logic read,	
	output logic [7:0] readdata,

	input logic write,
	input logic [7:0] writedata,
	input logic [15:0] address
);

wire [7:0] nes_d_in;
wire [7:0] nes_d_out;
wire [7:0] nes_addr;

wire main_clock = clk;

cpu c (
	.clk (main_clock),
	.reset (),
   .ready (),
    .irq (),
    .nmi (),
     .d_in(),
	  
     .write(),
     .sync(),
     .d_out(),
     .addr()
);

mixed_width_true_dual_port_ram_new_rw mem (
		.addr1 (),
		.addr2 (),
		.data_in1 (), 
		.data_in2 (), 
		.we1 (), .we2 (),
		.clk (main_clock),
		
		.data_out1 (),
		.data_out2 ();
);
endmodule
