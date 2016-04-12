module alu (input [7:0] alu_a,
            input [7:0] alu_b, 
	    input [4:0] mode,
	    input carry_in,
	    output [7:0] alu_out,
	    output carry_out,
    	    output overflow);
   
   always_comb begin
      carry_out = 0;
      overflow = 0;
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
	 SBC: begin
	      alu_out = alu_a - alu_b;
	      if (alu_b >= 0)
	         overflow = alu_out > alu_a;
	      else 
	         overflow = alu_out < alu_a;
	      end
/*
         // TODO: verify direction/orientation	      
	 ASL: begin
	      carry_out = alu_a[0];
	      alu_out = alu_a << 1;
	      end
	 ROL: begin
	      carry_out = alu_a[0];
	      alu_out = alu_a << 1;
	      alu_out[7] = carry_in;
	      end
	 LSR: begin
	      carry_out = alu_a[7];
              alu_out = alu_a >> 1;
	      end
	 ROR: begin
	      carry_out = alu_a[7];
	      alu_out = alu_a >> 1;
	      alu_out[0] = carry_in;
	      end
*/

   	 default: alu_out = alu_a; 
      endcase
   end

endmodule

