
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

   /*
    * OP CODES
    */

    parameter
        ORA = 3'b000,
        AND = 3'b001,
        EOR = 3'b010,
        ADC = 3'b011,
        STA = 3'b100,
        LDA = 3'b101,
        CMP = 3'b110,
        SBC = 3'b111,

        ZPX = 3'b000,
        ZP  = 3'b001,
        IMM = 3'b010,
        ABS = 3'b011,
        ZPY = 3'b100,
    ;    
endmodule // cpu
