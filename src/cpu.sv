module cpu (input clk,
			input rst,
			input [7:0] d_in,
			output [7:0] d_out,
			output [15:0] addr);

   logic [7:0] pcl;
   logic [7:0] pch;

   assign d_out = 0;
   assign addr = 0;

   /*
    * Program Counter Logic
    */

   // TODO: account for not incrementing on singl

   always_ff @ (posedge clk) begin
	  if (rst) begin
         pcl <= 8'h00;
         pch <= 8'h00;
	  end
      else begin
         if (pcl == 8'hff)
           pch <= pch + 1;
      end
      pcl <= pcl + 1;
   end

endmodule // cpu
