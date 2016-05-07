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
               D_OUT, // data output
               IR,    // instruction register
               P,     // processor status
               PCH,   // program counter high
               PCL,   // program counter low
               SP;    // stack pointer


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
          DECODE: begin
             casex (d_in)
               default: state <= FETCH; // Immediate
             endcase
          end

          default: state <= FETCH;
        endcase;

        $display("A:%b X:%b Y:%b", A, X, Y);
     end


   /*
    * Instruction Register
    */

   always_ff @ (posedge clk)
     begin
        if (state == DECODE)
          IR <= d_in;
     end

   always_ff @ (posedge clk)
     begin
        case (state)
          default: A <= d_in;
        endcase;
     end

   always_ff @ (posedge clk)
     begin
        case (state)
          default: X <= d_in;
        endcase;
     end

   always_ff @ (posedge clk)
     begin
        case (state)
          default: Y <= d_in;
        endcase;
     end

   /*
    * Program Counter
    */

   always_ff @ (posedge clk)
     begin
        case (state)
          default: {PCH, PCL} <= {PCH, PCL} + 1;
        endcase;
     end


   /*
    * Address Output
    */

   assign addr = {PCH, PCL};
 	// always_comb
    //   begin
	// 	 if (state != ABS_T3 && state != ZP_T2)
	// 	   addr = {PCH, PCL};
	// 	 else if (state == ABS_T3 || state == ZP_T2)
	// 	   addr = {abh, ABL};
	// 	 else
	// 	   addr = {PCH, PCL};
	//   end


   /*
    * alu_a, alu_b control
    */

   always_comb
     begin
        case (state)
          default: alu_a = A;
        endcase;
     end

   always_comb
     begin
        case (state)
          default: alu_b = d_in;
        endcase;
     end


   /*
    * Data Bus
    */

   logic [7:0] dbus;
   always_comb
     begin
        case (state)
          default: dbus = d_in;
        endcase;
     end


   /*
    * ALU
    */

   logic [7:0] alu_a, alu_b, alu_out;
   alu ALU(
		   .alu_a(alu_a),
	       .alu_b(alu_b),
		   .mode(ALU_ADD),
	       .carry_in(0),
	       .alu_out(alu_out),
	       .carry_out(P[0]),
		   .overflow(P[6]),
		   .zero(P[1]),
		   .sign(P[7])
           );

endmodule; // cpu
