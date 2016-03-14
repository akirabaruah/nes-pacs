module reg8_tb;
   reg clk, reset, load;
   reg [7:0] in;
   wire [7:0] out;

   // Device under test
   register dut (.*);

   // Initial state
   initial begin
	  clk = 0;
	  reset = 0;
	  load = 1;
	  in = 0;
   end

   // Test procedure
   initial begin
	  in = 8'h2a;
	  reset = 1;
	  #3  load = 1; reset = 0;
	  #10 load = 0; in = 8'h7b;
	  #10 reset = 1;
	  #10 reset = 0;
	  #10 load = 1;
	  #7  $finish;
   end

   // Clock
   always begin
	  #5 clk = !clk;
   end

   // Waveform
   initial begin
	  $dumpfile("register.vcd");
	  $dumpvars;
   end

   // Monitor
   initial begin
	  $display("%8s,%8s,%8s,%8s,%8s,%8s",
			   "time", "clk", "reset", "load", "in", "out");
	  $monitor("%8d,%8b,%8b,%8b,%8x,%8x", $time, clk, reset, load, in, out);
   end

endmodule // reg8_tb
