module alu (input [7:0] alu_a,
            input [7:0] alu_b, 
	    input [4:0] mode,
	    input carry_in,
	    output [7:0] alu_out,
	    output carry_out,
    	    output overflow);

//   assign carry_out = 0;
//   assign verflow = 0;

//   if (AND == 00101) 
//     carry_out = 1;
   
   
   always_comb begin
      case (mode)
	 ADC: begin 
	      alu_out = alu_a + alu_b; 
	      if (alu_a > 0 && alu_b > 0) 
                 overflow = alu_out < alu_a;
	      else if (alu_a < 0 && alu_b < 0)
                 overflow = alu_out > alu_a; 
      	      end
	 AND: alu_out = alu_a & alu_b;
	 ORA: alu_out = alu_a | alu_b;
	 EOR: alu_out = alu_a ^ alu_b;
// 	 no SRS code yet
//	 SRS: begin 
//	      carry_out = alu_a[7]; 
// 	      alu_out = alu_a >> 1; 
//	      end    // Shifting always uses alu_a register?? 
	 default: alu_out = alu_a; 
      endcase
   end

endmodule

