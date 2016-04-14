
/*
 * Single byte instructions
 */

parameter
  CLC = 8'h18,
  CLD = 8'hD8,
  CLI = 8'h58,
  CLV = 8'hB8,
  DEX = 8'hCA,
  DEY = 8'h88,
  INX = 8'hE8,
  INY = 8'hC8,
  NOP = 8'hEA,
  SEC = 8'h38,
  SED = 8'hF8,
  SEI = 8'h78,
  TAX = 8'hAA,
  TAY = 8'hA8,
  TSX = 8'hBA,
  TXA = 8'h8A,
  TXS = 8'h9A,
  TYA = 8'h98
;

/*
 * Opcodes {aaa, cc}
 */

parameter
  ORA = 5'b000_10,
  AND = 5'b001_10,
  EOR = 5'b010_10,
  ADC = 5'b011_10,
  STA = 5'b100_10,
  LDA = 5'b101_10,
  CMP = 5'b110_10,
  SBC = 5'b111_10,

  ASL = 5'b000_01,
  ROL = 5'b001_01,
  LSR = 5'b010_01,
  ROR = 5'b011_01,
  STX = 5'b100_01,
  LDX = 5'b101_01,
  DEC = 5'b110_01,
  INC = 5'b111_01,

  BRK = 5'b000_00,
  BIT = 5'b001_00,
  JMP = 5'b010_00,
  JMP_abs = 5'b011_00,
  STY = 5'b100_00,
  LDY = 5'b101_00,
  CPY = 5'b110_00,
  CPX = 5'b111_00;

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

   logic [7:0] A,     // accumulator
               X,     // X index
               Y,     // Y index
               ALU_A, // ALU input A
               ALU_B, // ALU input B
               D_OUT, // data output
               IR,    // instruction register
               P,     // processor status
               PCH,   // program counter high
               PCL,   // program counter low
               SP;    // stack pointer

   assign d_out = D_OUT;
   assign addr = {PCH, PCL};


   /*
    * Buses
    */

   logic [7:0] bus_d, bus_s;


   /*
    *  Processor status flags
	*/

   logic P_C, // carry
         P_Z, // zero result
         P_I, // interrupt disable
         P_D, // decimal mode
         P_B, // break command
         P_X, // nothing
         P_V, // overflow
         P_N; // negative result

   assign P = {P_C, P_Z, P_I, P_D, P_B, P_X, P_V, P_N};


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
      if (state == T0)
        IR <= d_in;
   end


   /*
    * Predecode logic
    */

   always_comb begin

   end


   /*
    * Controller FSM
    */

   enum {T0, T1, T2, T3, T4, T5, T6} state;
   initial state = T0;

   parameter
     INX = 3'b000,
     ZPG = 3'b001,
     IMM = 3'b010,
     ABS = 3'b011,
     INY = 3'b100,
     ZPX = 3'b101,
     ABY = 3'b110,
     ABX = 3'b111;

   always_ff @ (posedge clk) begin

      case (state)
        T0: begin
           state <= T1;
           if (bbb == IMM)
             A <= bus_s;
        end
        T1: state <= (bbb == IMM) ? T0 : T2;
        T2: state <= (bbb == ZPG) ? T0 : T3;
        T3:
          if (bbb == ABS || bbb == ZPX)
            state <= T0;
          else if ((bbb == ABX || bbb == ABY) && !P[0])
            state <= T0;
          else
            state <= T4;
        T4:
          if (bbb == ABX || bbb == ABY)
            state <= T0;
          else if (bbb == INY && !P[0])
            state <= T0;
          else
            state <= T5;
        T5: state <= T0;
        default: state <= T0;
      endcase

      $display("state: T%.1d, IR: %x, bus_s: %x, A: %x", state, IR, bus_s, A);
      $display("IMM: %.1d, bbb: %.1d", IMM, bbb);

   end


   /*
    * Control logic
    */

   always_comb begin

      casex ({state,bbb})
        {T1, IMM}: begin
           bus_d = d_in;
           bus_s = A;
        end
        {T0, IMM}: begin
           bus_d = alu_out;
           bus_s = A;
        end
      endcase

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

   logic [7:0] alu_out;
   logic       carry_out;

   alu cpu_alu (.alu_a(ALU_A),
                .alu_b(ALU_B),
                .mode(opcode),
                .carry_in(0),
                .alu_out(alu_out),
                .carry_out(carry_out),
                .overflow(P_V)
                );

endmodule // cpu
