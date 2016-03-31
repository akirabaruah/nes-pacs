module decode (input [7:0] opcode);

   enum {IMPLICIT,
         ACCUMULATOR,
         IMMEDIATE,
         ZEROPAGE,
         ZEROPAGE_X,
         ZEROPAGE_Y,
         RELATIVE,
         ABSOLUTE,
         ABSOLUTE_X,
         ABSOLUTE_Y,
         INDIRECT,
         INDEXED_INDIRECT,
         INDIRECT_INDEXED
         } mode;

   logic [2:0] aaa;
   logic [2:0] bbb;
   logic [1:0] cc;

   assign {aaa,bbb,cc} = opcode;

   case (cc)
     2'b00: begin
     end
     2'b01: begin
        case (aaa)
          3'b010: addr_mode <= IMM
        endcase
     end
     2'b10: begin
     end
   endcase

endmodule // decode
