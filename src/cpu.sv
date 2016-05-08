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

   initial state = FETCH;

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

        $display("sync:%b addr:%x d_in:%x A:%x X:%x Y:%x a:%x b:%x: out:%x P:%x",
                 sync, addr, d_in, A, X, Y, alu_a, alu_b, alu_out, P);
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
    * Accumulator
    */

   always_ff @ (posedge clk)
     begin
        case (state)
          default: A <= d_in;
        endcase;
     end

   /*
    * X Index Register
    */

   always_ff @ (posedge clk)
     begin
        case (state)
          default: X <= d_in;
        endcase;
     end

   /*
    * Y Index Register
    */

   always_ff @ (posedge clk)
     begin
        case (state)
          default: Y <= d_in;
        endcase;
     end

   /*
    * Processor Status Register
    */

   always_ff @ (posedge clk)
     begin
        case (state)
          default: P <= {sign, over, X[0], Y[0], 2'b00, zero, cout}; // some bs
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
   logic [4:0] alu_mode;
   logic cout, over, zero, sign;
   alu ALU(
		   .alu_a(alu_a),
	       .alu_b(alu_b),
		   .mode(alu_mode),
	       .carry_in(0),
	       .alu_out(alu_out),
	       .carry_out(cout),
		   .overflow(over),
		   .zero(over),
		   .sign(sign)
           );

   always_comb
     begin
        casex (IR)
          8'b000xxx01: alu_mode = ALU_OR;
          8'b001xxx01: alu_mode = ALU_AND;
          8'b010xxx01: alu_mode = ALU_EOR;
          8'b011xxx01: alu_mode = ALU_ADD;
          8'b111xxx01: alu_mode = ALU_SUB;
          8'b010xxx10: alu_mode = ALU_SR;

          default: alu_mode = ALU_ADD;
        endcase
     end


   /*
    * SYNC Signal
    */

   assign sync = (state == DECODE);

endmodule; // cpu
