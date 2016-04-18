
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
        T0:
          casex (d_in)
            8'bxxx_010_01: state <= IMM_T1;
          endcase

        IMM_T1: state <= T0;

        default: state <= T0;
      endcase

      $display("state: T%.1d, IR: %x, bus_s: %x, A: %x", state, IR, bus_s, A);
      $display("IMM: %.1d, bbb: %.1d", IMM, bbb);

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

   /* Buses */
   logic db, sb;

   /*
    * Control logic
    */

   always_ff @ (posedge clk) begin
      casex (state)

        IMM_T1: begin
           A <= d_in;
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
