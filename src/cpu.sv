 
   /*
    * OP CODES
    */

    parameter
        ORA = 5'b00001,
        AND = 5'b00101,
        EOR = 5'b01001,
        ADC = 5'b01101,
        STA = 5'b10001,
        LDA = 5'b10101,
        CMP = 5'b11001,
        SBC = 5'b11101,

        ZPX = 5'b00001,
        ZP  = 5'b00101,
        IMM = 5'b01001,
        ABS = 5'b01101,
        ZPY = 5'b10001
    ;    

module cpu (input clk,
			input rst,
			input [7:0] d_in,
			output [7:0] d_out,
			output [15:0] addr);

   logic [7:0] pcl; // Program counter low
   logic [7:0] pch; // Program counter high

   logic [15:0] pc_temp = {pch, pcl};
   logic [7:0] status; // Processor flags
   logic [7:0] acc; // Accumulator

   logic [7:0] alu_a; // ALU A register
   logic [7:0] alu_b; // ALU B register

   logic [4:0] alu_mode;


   /*
    * Decode instruction
    */   
     
   assign alu_mode = {d_in[7:5], d_in[1:0]};

initial 
   assign acc = 1;

   alu ALU(.alu_a(alu_a),
	   .alu_b(alu_b),
	   .carry_in(status[1]),
	   .mode(alu_mode),
	   .alu_out(d_out),
	   .carry_out(status[0]));


   // TODO: MISSING!!!!!!
   // alu_b needs to get data from other places
   // like X, Y, PCL/PCH????

   always_ff @(posedge clk) begin
      alu_b <= d_in;
      alu_a <= acc;
      acc   <= d_out;
      $display("acc: %h\n", acc);
   end

   /* 
    *  Processor status flags
	*  C - Carry
	*  Z - Zero Result
	*  I - Interrupt Disable
	*  D - Decimal Mode
	*  B - Break Command
	*  X - Nothing
	*  V - Overflow
	*  N - Negative Result
	*/







   assign d_out = 0;
   assign addr = 0;
   
   assign pc_rst = 0;

   /*
    * Program Counter Logic
    */

   // TODO: account for not incrementing on singl


   pc PC( .clk(clk),
          .rst(pc_rst),
          .pc_in(pc_temp),
          .pc_out(pc_temp));
   assign addr = pc_temp;
endmodule // cpu
