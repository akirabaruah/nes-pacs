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

	// for right shift, alu_b will be zero
	assign   alu_out = tmp_out[7:0];
	assign   overflow = alu_a[7] ^ alu_b[7] ^ tmp_out[7];
	assign	carry_out = tmp_out[8];
	assign	sign = tmp_out[7];
	assign	zero = tmp_out == 0;

	always_comb begin
		case (mode)
			ALU_ADD: begin tmp_out = alu_a + alu_b + carry_in; end
			ALU_SUB: begin tmp_out = alu_a - alu_b + carry_in; end
			ALU_AND: begin tmp_out = alu_a & alu_b; end
	 		ALU_OR : tmp_out = alu_a | alu_b;
	 		ALU_EOR: tmp_out = alu_a ^ alu_b;
	 		ALU_SR : begin tmp_out = {alu_a[0], carry_in, alu_a[7:1]}; end //ASL,

			default begin tmp_out = alu_a; end
		endcase
	end
endmodule
