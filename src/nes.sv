parameter
   HALT  = 8'b0,
   START = 8'b1,
   WRITE = 8'b2
;

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
logic cpu_ready;
logic sync;
logic cpu_write, mem_write;
logic [15:0] cpu_addr, mem_addr;
logic [7:0] d_in, d_out, mem_in, mem_out;

logic [7:0] nes_op;                       // our own NES opcodes
assign nes_op = writedata[15:8];

cpu c (
   .clk (clk),
   .reset (reset),
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
      START: cpu_ready <= 1;
      STOP: begin
         mem_write <= 0;
         cpu_ready <= 0;
         end
      WRITE: begin
         mem_write <= 1;
         mem_addr <= writedata[7:0];
         end
      default:
         cpu_ready <= 1;
   endcase
end

endmodule
