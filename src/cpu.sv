/*
 * Opcodes {aaa, cc}
 */

parameter
  ORA = 5'b000_01,
  AND = 5'b001_01,
  EOR = 5'b010_01,
  ADC = 5'b011_01,
  STA = 5'b100_01,
  LDA = 5'b101_01,
  CMP = 5'b110_01,
  SBC = 5'b111_01,

  ASL = 5'b000_10,
  ROL = 5'b001_10,
  LSR = 5'b010_10,
  ROR = 5'b011_10,
  STX = 5'b100_10,
  LDX = 5'b101_10,
  DEC = 5'b110_10,
  INC = 5'b111_10,

  BRK = 5'b000_00,
  BIT = 5'b001_00,
  JMP = 5'b010_00,
  JMP_abs = 5'b011_00,
  STY = 5'b100_00,
  LDY = 5'b101_00,
  CPY = 5'b110_00,
  CPX = 5'b111_00;



parameter
	ALU_ADD = 0,
	ALU_AND = 1,
	ALU_OR  = 2,
	ALU_EOR = 3,
	ALU_SR  = 4,
   ALU_SUB = 5
;

/*
 * Addressing Modes
 */

// TODO

module cpu (input clk,
   			input rst,
   			input [7:0] d_in,
   			output [7:0] d_out,
   			output [15:0] addr);

   /*
    * Registers
    */

   logic [4:0] alu_mode;
   logic [4:0] alu_instruction;
   logic [7:0] A,     // accumulator
               X,     // X index
               Y,     // Y index
               alu_a, // ALU input A
               alu_b, // ALU input B
               D_OUT, // data output
               IR,    // instruction register
               P,     // processor status
               PCH,   // program counter high
               PCL,   // program counter low
               SP;    // stack pointer

   assign d_out = D_OUT;
   assign addr = {PCH, PCL};

	logic temp_carry_out;
	logic temp_carry_in;

   /*
    * Instruction Fields
    */

   logic [2:0] aaa;
   logic [2:0] bbb;
   logic [1:0] cc;
   logic [4:0] opcode;

   assign {aaa, bbb, cc} = IR;
   assign opcode = {aaa, cc};

   always_ff @ (posedge clk) begin
      if (state == T0) begin
        IR <= d_in;
	   end
   end

   /*
    * Control signals
    */

   /* Writer to DB */
   parameter
     DB_d_in = 3'd0,
     DB_A = 3'd1,
     DB_PCL = 3'd2,
     DB_PCH = 3'd3,
     DB_P = 3'd4;

   /* Writer to SB */
   parameter
     SB_ALU = 3'd0,
     SB_A = 3'd1,
     SB_X = 3'd2,
     SB_Y = 3'd3,
     SB_SP = 3'd3;



   /*
    * Controller FSM
    */

   enum {
         /* Indexed Indirect X */
         INX_T1,
         INX_T2,
         INX_T3,
         INX_T4,
         INX_T5,

         /* Zero page */
         ZP_T1,
         ZP_T2,

         /* Immediate */
         IMM_T1,

         /* Absolute */
         ABS_T1,
         ABS_T2,
         ABS_T3,

         /* Indirect Indexed Y */
         INY_T1,
         INY_T2,
         INY_T3,
         INY_T4,
         INY_T5,

         /* Absolute X */
         ABSX_T1,
         ABSX_T2,
         ABSX_T3,
         ABSX_T4,

         /* Absolute X */
         ABSY_T1,
         ABSY_T2,
         ABSY_T3,
         ABSY_T4,

         /* Decode state */
         T0
         } state;

   initial state = T0;

   always_ff @ (posedge clk) begin

      case (state)
        T0:begin
          casex (d_in)
			 	8'bxxx_011_01: state <= ABS_T1; // STA
            8'bxxx_010_01: state <= IMM_T1; 
          endcase
			 end
        IMM_T1: begin 
					state <= T0; 
			end

		  ABS_T1:begin
						// get absolute address
						state <= ABS_T2;
		  			end
			ABS_T2:begin
						
						if (opcode == STA) begin
							D_OUT <= A; // testing STA absolute 100_011_01
						end
						state <= T0;
					end

        default: state <= T0;
      endcase

   $display("alu_a = %b", alu_a);
   $display("alu_b = %b", alu_b);
	$display("db = %b", db);
	$display("alu_out = %b", alu_out);
	$display("acc = %b", A);
	$display("din = %b", d_in);
	$display("dout = %b", d_out);

//      $display("state: T%.1d, IR: %x, bus_s: %x, A: %x", state, IR, bus_s, A);
//      $display("IMM: %.1d, bbb: %.1d", IMM, bbb); 
   end

   /* Buses */
   logic [7:0] db;
   logic [7:0] sb;


   /*
	 * Bus logic
	 */
/*
	always_comb begin
		case(state)
			IMM_T1:
			casex(IR)
            8'b000x_xxxx: db = alu_out; // ORA
            8'b001x_xxxx: db = alu_out; // AND
            8'b010x_xxxx: db = alu_out; // EOR
            8'b011x_xxxx: db = alu_out; // ADC
            8'b100x_xxxx: db = alu_out; // STA
            8'b101x_xxxx: db = d_in; // LDA
            8'b110x_xxxx: db = alu_out; // CMP
            8'b111x_xxxx: db = alu_out; // SBC
			endcase
		endcase
	end
*/



   /*
    * Control logic
    */

   always_comb begin
			case (state)
			IMM_T1:
				if (aaa == 3'b000 || aaa == 3'b001  
				 || aaa == 3'b010 || aaa == 3'b011
				 || aaa == 3'b111)   //  ORA, AND, EOR, ADC, SBC
					alu_b = d_in;
			endcase
//				if (aaa == 3'b011) // This is T2, the final cycle of ADC
//           		A <= alu_out; 
//        		end
//		  IMM_T1: begin
//				if (aaa == 3'b011) // ADC
//					A = alu_out;
//				end
end
   /*
    * Program Counter Logic
    */

   always_ff @ (posedge clk) begin
      {PCH, PCL} <= {PCH, PCL} + 1;
   end


   /*
    * Arithmetic Logic Unit (ALU)
    */

   assign alu_instruction = opcode; // do we need this?


   always_ff @(posedge clk) begin

      //$display("alu_instruction: %b", alu_instruction);
	  //if (alu_instruction == ADC)

		// if it is a right shift operation, alu_b needs to be zero

	  case (alu_instruction)
		AND: alu_mode <= ALU_AND;
		ADC: alu_mode <= ALU_ADD; 
		ORA: alu_mode <= ALU_OR;
		EOR: alu_mode <= ALU_EOR;
		SBC: alu_mode <= ALU_SUB;
		default: alu_mode <= ALU_ADD;
	  endcase

		// At the moment the accumulator is writing to alu_a every cycle
	   alu_a <= A;


		// This variable is set to the value of the carry flag every cycle
      carry_in_temp <= P[0];
	

		if (state == IMM_T1)
			if (aaa == 3'b000 || aaa == 3'b001  
				 || aaa == 3'b010 || aaa == 3'b011
				 || aaa == 3'b111)   //  ORA, AND, EOR, ADC, SBC
				A = alu_out;
			else if (aaa == 3'b101) // This operation was previously being performed in the comb logic above, which allowed the
				A = d_in;            // accumulator to be set from LDA on cycle T1. Here it is loaded on cycle T2/T0 of the next
											// instruction. I moved it here because I thought registers should only be loaded on the
											// clock. Thoughts?

   end

   // TODO: MISSING!!!!!!
   // alu_b needs to get data from other places
   // like X, Y, PCL/PCH????

   logic [7:0] alu_out;
   alu ALU(
		   .alu_a(alu_a),
	      .alu_b(alu_b),
		   .mode(alu_mode),
	      .carry_in(carry_in_temp),
	      .alu_out(alu_out),
	      .carry_out(P[0]),
		   .overflow(P[6]),
		   .zero(P[1]),
		   .sign(P[7]));

endmodule // cpu
