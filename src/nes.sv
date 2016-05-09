parameter
   RESET_CPU = 8'd0,
   START_CPU = 8'd1,
   PAUSE_CPU = 8'd2
   WRITE_MEM = 8'd3,
;

module nes (
   input logic clk,
   input logic reset,               // obsolete
   input logic chipselect,          // ??
   input logic read,                // obsolete
   input logic write,               // obsolete
   input logic [15:0] writedata,
   input logic [15:0] address,
   output logic [7:0] readdata
);

logic zero = 0;
logic one = 1;

logic cpu_ready;
logic sync;
logic cpu_write, mem_write, cpu_reset;
logic [15:0] cpu_addr, mem_addr, pc;
logic [7:0] d_in, d_out, mem_in, mem_out;
logic [7:0] nes_op;                       // our own NES opcodes

assign d_in = writedata[7:0]
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
         cpu_ready <= 0;
         cpu_reset <= 1;
         end
      WRITE_MEM: begin
         mem_write <= 1;
         cpu_ready <= 0;
         mem_addr <= address;
         mem_in <= d_in;
         end
      PAUSE_CPU: begin
         mem_write <= 0;
         cpu_ready <= 0;
         cpu_reset <= 0;
         end
      START_CPU: begin
         mem_write <= 0;
         cpu_ready <= 1;
         cpu_reset <= 0;
         cpu_addr <= address;
         end
      default: begin             // keep running CPU
         mem_write <= 0;
         cpu_ready <= 1;
         cpu_reset <= 0;
         cpu_addr <= cpu_addr+1;
         end
   endcase

   readdata <= d_out;

   $display("nes_op:%d  d_in:%b  addr:%x  d_out:%b",
      nes_op, d_in, addr, d_out);
end


endmodule
