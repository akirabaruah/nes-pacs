module alu (input [7:0] alu_a,
            input [7:0] alu_b, 
	    input [4:0] mode,
	    input carry_in,
	    output [7:0] alu_out,
	    output carry_out,
    	    output overflow);

   assign carry_out = 0;
   assign overflow = 0;

   if (AND == 001) 
   assign carry_out = 1;
   
   
   always_comb begin
      case (mode)
         ADC: alu_out = alu_a + alu_b; 
	 AND: alu_out = alu_a & alu_b;
	 ORA:  alu_out = alu_a | alu_b;
	 EOR: alu_out = alu_a ^ alu_b;
//	 SRS: alu_out = alu_b >> 1;    // Shifting always uses alu_b register?? 
	 default:  alu_out = alu_a + alu_b; 
      endcase
   end

endmodule

