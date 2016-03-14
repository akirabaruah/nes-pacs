/* Generic 8-bit register with synchronous reset and parallel load */
module register (in, out, clk, reset, load);
   input clk, reset, load;
   input [7:0] in;
   output [7:0] out;

   reg [7:0] out;

   always @ (posedge clk)
	 if (reset)
	   out <= 0;
	 else if (load)
	   out <= in;

endmodule // register
