parameter
   RESET_CPU  = 8'd0,
   START_CPU = 8'd1,
   START_WRITE = 8'd2,
   WRITE = 8'd3,
   STOP_WRITE = 8'd4
;

module nes (
   input logic clk,
   input logic reset,
   input logic chipselect,
   input logic read, 
   output logic [15:0] readdata,
   input logic write,
   input logic [15:0] writedata,
   input logic [15:0] address,
	
	 output [14:0] hps_memory_mem_a,
    output [2:0]  hps_memory_mem_ba,
    output        hps_memory_mem_ck,
    output        hps_memory_mem_ck_n,
    output        hps_memory_mem_cke,
    output        hps_memory_mem_cs_n,
    output        hps_memory_mem_ras_n,
    output        hps_memory_mem_cas_n,
    output        hps_memory_mem_we_n,
    output        hps_memory_mem_reset_n,
    inout  [39:0] hps_memory_mem_dq,
    inout  [4:0]  hps_memory_mem_dqs,
    inout  [4:0]  hps_memory_mem_dqs_n,
    output        hps_memory_mem_odt,
    output [4:0]  hps_memory_mem_dm,
    input         hps_memory_oct_rzqin
);

logic zero = 0;
logic one = 1;
logic cpu_ready;
logic sync;
logic cpu_write, mem_write, cpu_reset;
logic [15:0] cpu_addr, mem_addr;
logic [7:0] d_in, d_out, mem_in, mem_out;
logic [15:0] program_end = 0;

logic [7:0] nes_op;                       // our own NES opcodes
assign nes_op = writedata[15:8];

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
         mem_write <= 0;
         cpu_reset <= 1;
         program_end <= 0;
         end
      START_CPU: begin
         cpu_ready <= 1;
         cpu_reset <= 0;
         end
      START_WRITE: begin
         mem_addr <= address;
         program_end <= address + 1;
         mem_write <= 1;
         mem_in <= writedata[7:0];
         end
      WRITE: begin
         mem_write <= 1;
         mem_addr <= mem_addr + 1;
         program_end <= program_end + 1;
         mem_in <= writedata[7:0];
         end
      STOP_WRITE: begin
         mem_write <= 0;
         end
      default: begin
         mem_write <= 0;
         cpu_ready <= 0;
         end
   endcase
end

soc_system soc (
    .memory_mem_a        (hps_memory_mem_a),
    .memory_mem_ba       (hps_memory_mem_ba),
    .memory_mem_ck       (hps_memory_mem_ck),
    .memory_mem_ck_n     (hps_memory_mem_ck_n),
    .memory_mem_cke      (hps_memory_mem_cke),
    .memory_mem_cs_n     (hps_memory_mem_cs_n),
    .memory_mem_ras_n    (hps_memory_mem_ras_n),
    .memory_mem_cas_n    (hps_memory_mem_cas_n),
    .memory_mem_we_n     (hps_memory_mem_we_n),
    .memory_mem_reset_n  (hps_memory_mem_reset_n),
    .memory_mem_dq       (hps_memory_mem_dq),
    .memory_mem_dqs      (hps_memory_mem_dqs),
    .memory_mem_dqs_n    (hps_memory_mem_dqs_n),
    .memory_mem_odt      (hps_memory_mem_odt),
    .memory_mem_dm       (hps_memory_mem_dm),
    .memory_oct_rzqin    (hps_memory_oct_rzqin),

    .clk_clk (main_clk),
    .reset_reset_n (!cpu_reset)
);

endmodule
