module mixed_width_true_dual_port_ram_new_rw(
   input logic [15:0] addr1, addr2,
   input logic [7:0] data_in1, data_in2,
   input logic we1, we2,
   input logic clk,
   output logic [7:0] data_out1, data_out2);

logic [7:0] mem [65535:0];   // 65536-size array of 8-bit elements

always_ff @(posedge clk) begin
   if (we1) 
      mem[addr1] <= data_in1;
   data_out1 <= mem[addr1];
end

always_ff @(posedge clk) begin
   if (we2) 
      mem[addr2] <= data_in2;
   data_out2 <= mem[addr2];
end

endmodule