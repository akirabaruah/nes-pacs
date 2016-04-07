
module cpu (input clk,
			input rst,
			input [7:0] d_in,
			output [7:0] d_out,
			output [15:0] addr);

   logic [7:0] pcl;
   logic [7:0] pch;

   /*
    * Instruction Fields
    */

   logic [2:0] aaa;
   logic [2:0] bbb;
   logic [1:0] cc;
   assign {aaa, bbb, cc} = d_in;

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


   /*
    * Controller FSM
    */

   enum {T0, T1, T2, T3, T4, T5, T6} state;
   initial state = T0;

   always_ff @ (posedge clk) begin

      case (state)
        T0: state <= T1;
        T1: state <= T2;
        T2: state <= T3;
        T3: state <= T4;
        T4: state <= T5;
        T5: state <= T6;
        T6: state <= T0;
        default: state <= T0;
      endcase

      $display("\n%x\n", state);
   end

   /*
    * Program Counter Logic
    */

   assign d_out = 0;
   assign addr = 0;
   assign pc_rst = 0;

   // TODO: account for not incrementing on singl

   logic [15:0] pc_temp = {pch, pcl};

   pc PC( .clk(clk),
          .rst(pc_rst),
          .pc_in(pc_temp),
          .pc_out(pc_temp));

   assign addr = pc_temp;

endmodule // cpu
