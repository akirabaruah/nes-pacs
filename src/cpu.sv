parameter
  ALU_ADD = 0,
  ALU_AND = 1,
  ALU_OR  = 2,
  ALU_EOR = 3,
  ALU_SR  = 4,
  ALU_SUB = 5;


module cpu (
            input clk,
            input reset,
            input ready,
            input irq,
            input nmi,
            input [7:0] d_in,
            output write,
            output sync,
            output [7:0] d_out,
            output [15:0] addr
            );

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
               SP,    // stack pointer
			   ABL,
			   ABH;

   /*
    * Controller FSM
    */

   enum {
         DECODE, // T0
         FETCH   // TX (final state of instruction)
         } state;

   always_ff @ (posedge clk)
     begin
        case (state)
          FETCH:   state <= DECODE;
          DECODE:  state <= FETCH;

          default: state <= FETCH;
        endcase
     end


   /*
    * Instruction Register
    */

   always_ff @ (posedge clk)
     begin
        if (state == DECODE)
          IR <= d_in;
     end


   /*
    * ALU
    */

   alu ALU(
		   .alu_a(alu_a),
	       .alu_b(alu_b),
		   .mode(0),
	       .carry_in(carry_in_temp),
	       .alu_out(alu_out),
	       .carry_out(P[0]),
		   .overflow(P[6]),
		   .zero(P[1]),
		   .sign(P[7])
           );

endmodule; // cpu
