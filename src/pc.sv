
module pc (input clk,
           input rst,
           input [15:0] pc_in,
           output [15:0] pc_out);

   always_ff @ (posedge clk) begin
        if (rst)
           pc_out <= 0;
        else
           pc_out <= pc_in + 1;
   end

endmodule



