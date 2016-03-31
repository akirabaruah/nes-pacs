
module cpu (input clk,
			input rst,
			input [7:0] d_in,
			output [7:0] d_out,
			output [15:0] addr);

   logic [7:0] pcl;
   logic [7:0] pch;

   assign d_out = 0;
   assign addr = 0;
   
   assign pc_rst = 0;

   /*
    * Program Counter Logic
    */

   // TODO: account for not incrementing on singl

   logic [15:0] pc_temp = {pch, pcl};

   pc PC( .clk(clk),
          .rst(pc_rst),
          .pc_in(pc_temp),
          .pc_out(pc_temp));

   assign addr = pc_temp;

endmodule // cpu
