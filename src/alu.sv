module alu (input [7:0] alu_a,
           input [7:0] alu_b,
		   input [2:0] mode,
		   input carry_in,
		   output [7:0] alu_out,
		   output carry_out,
		   output overflow);

   carry_out = 0;
   overflow = 0;

   parameter
      ALU_ADD = 3'd0,
	  ALU_AND = 3'd1,
	  ALU_OR  = 3'd2,
	  ALU_XOR = 3'd3,
	  ALU_SRS = 3'd4
   ;
   
   always_comb
      case (mode)
	

	  endcase
   end

   
endmodule



