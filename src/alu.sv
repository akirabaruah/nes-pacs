parameter
	ALU_ADD = 0,
	ALU_AND = 1,
	ALU_ORA = 2,
	ALU_EOR = 3,
	ALU_SHR = 4
;

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
			ALU_ADD: begin 
	      	alu_out = alu_a + alu_b + carry_in; 
	         if (alu_a > 0 && alu_b > 0) 
            	overflow = alu_out < alu_a;
	         else if (alu_a < 0 && alu_b < 0)
            	overflow = alu_out > alu_a; 
      	   end
			ALU_AND: alu_out = alu_a & alu_b;
	 		ALU_ORA: alu_out = alu_a | alu_b;
	 		ALU_EOR: alu_out = alu_a ^ alu_b;
	 		ALU_SHR: alu_out = alu_a << 1;

/*
	 SBC: begin
	      alu_out = alu_a - alu_b;
	      if (alu_b >= 0)
	         overflow = alu_out > alu_a;
	      else 
	         overflow = alu_out < alu_a;
	      end

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
	 ALU_SHR: begin
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
