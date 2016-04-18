parameter
	ALU_ADD = 0,
	ALU_AND = 1,
	ALU_OR  = 2,
	ALU_EOR = 3,
	ALU_SR  = 4,
	ALU_SUB = 5
;

// we are not implementing decimal / half carry

module alu (input [7:0] alu_a,
            input [7:0] alu_b, 
	    		input [4:0] mode,
	    		input carry_in,
	    		output [7:0] alu_out,
	    		output carry_out,
    	    	output overflow,
				output zero,
				output sign);
   
	logic [8:0] tmp_out; //9 bit add for easy overflow/carry checks
	
	assign alu_out = tmp_out[7:0];
	assign overflow = alu_a[7] ^ alu_b[7] ^ tmp_out[7];
	assign carry_out = tmp_out[8];

	always_comb begin
		//carry_out = 0;
		//overflow = 0;
      
		case (mode)
			ALU_ADD: tmp_out = alu_a + alu_b + carry_in; 
			ALU_SUB: tmp_out = alu_a + ~alu_b + carry_in;
			ALU_AND: tmp_out = alu_a & alu_b;
	 		ALU_OR : tmp_out = alu_a | alu_b;
	 		ALU_EOR: tmp_out = alu_a ^ alu_b;
	 		ALU_SR : tmp_out = {alu_a[0], carry_in, alu_a[7:1]};

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

			default: tmp_out = alu_a; 
		endcase

	end
endmodule
