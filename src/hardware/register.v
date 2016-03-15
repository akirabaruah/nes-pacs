/* Generic 8-bit register with synchronous reset and parallel load */
module register (clk, rst, load, in, out);
   input clk, rst, load;
   input [7:0] in;
   output [7:0] out;

   reg [7:0] 	out;

   always @ (posedge clk)
	 if (rst)
	   out <= 0;
	 else if (load)
	   out <= in;

endmodule // register
