parameter
  ALU_ADD = 0,
  ALU_AND = 1,
  ALU_OR  = 2,
  ALU_EOR = 3,
  ALU_SR  = 4,
  ALU_SUB = 5;


/*
 * Opcodes {aaa}
 */

parameter
  ORA = 3'b000,
  AND = 3'b001,
  EOR = 3'b010,
  ADC = 3'b011,
  STA = 3'b100,
  LDA = 3'b101,
  CMP = 3'b110,
  SBC = 3'b111,

  ASL = 3'b000,
  ROL = 3'b001,
  LSR = 3'b010,
  ROR = 3'b011,
  STX = 3'b100,
  LDX = 3'b101,
  DEC = 3'b110,
  INC = 3'b111,

  BRK = 3'b000,
  BIT = 3'b001,
  JMP = 3'b010,
  STY = 3'b100,
  LDY = 3'b101,
  CPY = 3'b110,
  CPX = 3'b111;


module cpu (
            input         clk,
            input         reset,
            input         ready,
            input         irq,
            input         nmi,
            input [7:0]   d_in,
            output        write,
            output        sync,
            output [7:0]  d_out,
            output [15:0] addr
            );

   /*
    * Instruction Fields
    */

   logic [2:0] aaa;
   logic [2:0] bbb;
   logic [1:0] cc;
   logic [4:0] opcode;

   assign {aaa, bbb, cc} = IR;
   assign opcode = {aaa, cc};
   //assign t1op = {d_in[7:5], d_in[1:0]};

   /*
	* Arith control signal
	*/

   logic arith;
   always_comb begin
	  case (aaa)
		LDA: 		arith = 0;

		ORA:		arith = 1;
		AND:		arith = 1;
		EOR:		arith = 1;
		ADC:		arith = 1;
		SBC:		arith = 1;
		default: arith = 0;
	  endcase
   end


   /*
    * Registers
    */

   logic [7:0]            A,     // accumulator
                          X,     // X index
                          Y,     // Y index
                          D_OUT, // data output
                          IR,    // instruction register
                          P,     // processor status
                          SP,    // stack pointer
                          ADL,   // address low
                          ADH;   // address high
   logic [15:0]           PC;    // program counter

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
   //  ORA, AND, EOR, ADC, SBC

   always_ff @ (posedge clk)
     begin
        case (state)
		  DECODE:
			case (aaa)
			  default: A <= A;
			endcase
		  FETCH: A <= arith ? alu_out : d_in;
		  default: 		A <= A;
        endcase;
     end

   /*
    * X Index Register
    */

   always_ff @ (posedge clk)
     begin
        case (state)
          default: X <= X + 1;
        endcase;
     end

   /*
    * Y Index Register
    */

   always_ff @ (posedge clk)
     begin
        case (state)
          default: Y <= Y + 1;
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
		  ABS2,
        INDX1,
        INDX2,
        INDX3,
        INDX4,
		  ABSY2,
		  ABSY3,
		  ABSX2,
		  ABSX3,
		  ZP1:     PC <= PC;
		  default: PC <= PC + 1;
        endcase
     end

   /*
    * Address Low Register
    */

   always_ff @ (posedge clk)
     begin
        case (state)
        ABS1:   ADL <= d_in;

        INDX3:  ADL <= d_in;

		  ZP1:	 ADL <= d_in;

		  ABSX1:	 ADL <= alu_out;

		  ABSY1:	 ADL <= alu_out;

          default: ADL <= ADL;
        endcase;
     end

   /*
    * Address High Register
    */

   always_ff @ (posedge clk)
     begin
        case (state)
          ABS2:    ADH <= d_in;

		    ABSX2:	 ADH <= alu_out;

		    ABSY2:	 ADH <= alu_out;

          default: ADH <= ADH;
        endcase;
     end

   logic [7:0] BAL;
   always_ff @ (posedge clk)
      begin
         case (state)
            INDX1: BAL <= alu_out;
            INDX2: BAL <= alu_out;
            INDX3: BAL <= alu_out;
         endcase
      end

   /*
    * Address Output
    */

   always_comb
     begin
        case (state)
         
        ABS2:   addr = {d_in, ADL};
   
        INDX2:  addr = {8'b0, BAL};
        INDX3:  addr = {8'b0, BAL};
        INDX4:  addr = {d_in, ADL};

		  ABSX2:	 addr = {d_in, ADL};
		  ABSX3:	 addr = {ADH, ADL};

		  ABSY2:	 addr = {d_in, ADL};
		  ABSY3:	 addr = {ADH, ADL};

		  ZP1:    addr = {8'b0, d_in};

          default: addr = PC;
        endcase;
     end


   /*
    * Controller FSM
    */

   enum {
         DECODE, // T0
         FETCH,  // TX (final state of instruction)

         ABS1,
         ABS2,

  		   ABSX1,
		   ABSX2,
		   ABSX3,

         ABSY1,
		   ABSY2,
		   ABSY3,

         INDX1,
         INDX2,
         INDX3,
         INDX4,

		   ZP1
         
			} state;

   initial state = FETCH;

   always_ff @ (posedge clk)
     begin
        case (state)
          FETCH:   state <= DECODE;
          DECODE: begin
             casex (d_in)
               8'bxxx01101,
               8'bxxx01110,
               8'bxxx01100: state <= ABS1;  // Absolute
               8'bxxx00101: state <= ZP1;   // Zero Page
               8'bxxx11101: state <= ABSX1; // Absolute X
               8'bxxx11001: state <= ABSY1; // Absolute Y
               8'bxxx00001: state <= INDX1; // Indirect, X

               default:     state <= FETCH; // Immediate
             endcase
          end

          INDX1:  state <= INDX2;
          INDX2:  state <= INDX3;
          INDX3:  state <= INDX4;
          INDX4:  state <= FETCH;

          ABS1:    state <= ABS2;
          ABS2:    state <= FETCH;

          ABSX1:   state <= ABSX2;
          ABSX2:   state <= P[0] ? ABSX3 : FETCH;
          ABSX3:   state <= FETCH;


          ABSY1:   state <= ABSY2;
          ABSY2:   state <= P[0] ? ABSY3 : FETCH;
          ABSY3:   state <= FETCH;

  		    ZP1:     state <= FETCH;

          default: state <= FETCH;
        endcase;

        $display("sync:%b addr:%x d_in:%x A:%x X:%x Y:%x a:%x b:%x: out:%x P:%x BAL:%x",
                 sync, addr, d_in, A, X, Y, alu_a, alu_b, alu_out, P, BAL);
     end



   /*
    * alu_a, alu_b control
    */

   always_comb
     begin
        case (state)

        INDX1: alu_a = X;
        INDX2: alu_a = BAL;

		  ABSX1: alu_a = X;
		  ABSX3: alu_a = ADH;

        ABSY1: alu_a = Y;
        ABSY3: alu_a = ADH;

		  FETCH: alu_a = arith ? A : d_in;

          default: alu_a = 0;
        endcase;
     end

   always_comb
     begin
        case (state)

        INDX1:  alu_b = d_in; // ADL 
        INDX2:  alu_b = 1;

		  ABSX1:	 alu_b = d_in; // ADL
		  ABSX3:	 alu_b = P[0];

        ABSY1:  alu_b = d_in; // ADL
        ABSY3:  alu_b = P[0];

		  FETCH:	 alu_b = d_in;
          default: alu_b = d_in;
        endcase;
     end

   /*
    * ALU carry in
    */

   always_comb
     begin
        case (state)
          ABSX2:   cin = P[0];
          ABSY2:   cin = P[0];
          default: cin = 0;
        endcase
     end

   /*
    * ALU
    */

   logic [7:0] alu_a, alu_b, alu_out;
   logic [4:0] alu_mode;
   logic       cin, cout, over, zero, sign;
   alu ALU(
		   .alu_a(alu_a),
	       .alu_b(alu_b),
		   .mode(alu_mode),
	       .carry_in(cin),
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

endmodule // cpu
