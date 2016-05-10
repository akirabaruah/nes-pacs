parameter
   RESET_CPU = 8'd0,
   START_CPU = 8'd1,
   PAUSE_CPU = 8'd2,
   WRITE_MEM = 8'd3
;

module nes (
   input logic clk,
   input logic reset,               // obsolete
   input logic chipselect,          // ??
   input logic read,                // obsolete
   input logic write,               // obsolete
   input logic [15:0] writedata,
   input logic [15:0] address,
   output logic [15:0] readdata,
	
	output wire [12:0] memory_mem_a,       // memory.mem_a
		output wire [2:0]  memory_mem_ba,      //       .mem_ba
		output wire        memory_mem_ck,      //       .mem_ck
		output wire        memory_mem_ck_n,    //       .mem_ck_n
		output wire        memory_mem_cke,     //       .mem_cke
		output wire        memory_mem_cs_n,    //       .mem_cs_n
		output wire        memory_mem_ras_n,   //       .mem_ras_n
		output wire        memory_mem_cas_n,   //       .mem_cas_n
		output wire        memory_mem_we_n,    //       .mem_we_n
		output wire        memory_mem_reset_n, //       .mem_reset_n
		inout  wire [7:0]  memory_mem_dq,      //       .mem_dq
		inout  wire        memory_mem_dqs,     //       .mem_dqs
		inout  wire        memory_mem_dqs_n,   //       .mem_dqs_n
		output wire        memory_mem_odt,     //       .mem_odt
		output wire        memory_mem_dm,      //       .mem_dm
		input  wire        memory_oct_rzqin    //       .oct_rzqin
);

logic zero = 0;
logic one = 1;

logic cpu_ready;
logic sync;
logic cpu_write, mem_write, cpu_reset;
logic [15:0] cpu_addr, mem_addr, pc;
logic [7:0] d_in, d_out, mem_in, mem_out;
logic [7:0] nes_op;                       // our own NES opcodes

//assign d_in = writedata[7:0];
//assign nes_op = writedata[15:8];

cpu c (
   .clk (clk),
   .reset (cpu_reset),
   .ready (cpu_ready),
   .irq (zero),
   .nmi (zero),
   .d_in (d_in),
   .write (cpu_write),
   .sync (sync),
   .d_out (d_out),
   .addr (cpu_addr)
);

memory mem (
   .clk (clk),
   .addr (mem_addr),
   .write (mem_write),
   .in (mem_in),
   .out (mem_out)
);

always_ff @(posedge clk) begin
   case (nes_op)
      RESET_CPU: begin
         cpu_ready <= 0;
         cpu_reset <= 1;
         end
      WRITE_MEM: begin
         cpu_ready <= 0;
         mem_write <= 1;
         mem_addr <= address;
         mem_in <= d_in;
         end
      PAUSE_CPU: begin
         cpu_ready <= 0;
         cpu_reset <= 0;
		end
      START_CPU: begin
         cpu_ready <= 1;
         cpu_reset <= 0;
         mem_in <= d_out;
         mem_write <= cpu_write;
         d_in <= mem_out;
         mem_addr <= cpu_addr;
         end
      default: begin             // keep running CPU
         mem_write <= 0;
         cpu_ready <= 1;
         cpu_reset <= 0;
         mem_in <= d_out;
         mem_write <= cpu_write;
         d_in <= mem_out;
         mem_addr <= cpu_addr;
         end
   endcase

   readdata <= d_out;

   $display("nes_op:%d  d_in:%b  addr:%x  d_out:%b",
      nes_op, d_in, addr, d_out);
end

soc_system soc (
	.clk (clk),
	.memory_mem_a			(memory_mem_a),       // memory.mem_a
	.memory_mem_ba			(memory_mem_ba),      //       .mem_ba
	.memory_mem_ck			(memory_mem_ck),      //       .mem_ck
	.memory_mem_ck_n		(memory_mem_ck_n),    //       .mem_ck_n
	.memory_mem_cke		(memory_mem_cke),     //       .mem_cke
	.memory_mem_cs_n		(memory_mem_cs_n),    //       .mem_cs_n
	.memory_mem_ras_n		(memory_mem_ras_n),   //       .mem_ras_n
	.memory_mem_cas_n		(memory_mem_cas_n),   //       .mem_cas_n
	.memory_mem_we_n		(memory_mem_we_n),    //       .mem_we_n
	.memory_mem_reset_n	(memory_mem_reset_n), //       .mem_reset_n
	.memory_mem_dq			(memory_mem_dq),      //       .mem_dq
	.memory_mem_dqs		(memory_mem_dqs),     //       .mem_dqs
	.memory_mem_dqs_n		(memory_mem_dqs_n),   //       .mem_dqs_n
	.memory_mem_odt		(memory_mem_odt),     //       .mem_odt
	.memory_mem_dm			(memory_mem_dm),      //       .mem_dm
	.memory_oct_rzqin		(memory_oct_rzqin)    //       .oct_rzqin
);

endmodule
