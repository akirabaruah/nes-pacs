module memory(
   input logic [15:0] addr,
   input logic [7:0] in,
   input logic write,
   input logic clk,
   output logic [7:0] out);

logic [7:0] mem [65535:0];   // 65536-size array of 8-bit elements

always_ff @(posedge clk) begin
   if (write) 
      mem[addr] <= in;
   out <= mem[addr];
end

endmodule