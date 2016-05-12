parameter
   RESET_CPU = 8'd0,
	START_CPU = 8'd1,
	PAUSE_CPU = 8'd2,
	WRITE_MEM = 8'd3
;


module delay_ctrl (
    input logic clk,
    input logic faster,
    input logic slower,
	 
	 input logic reset,
	 
	 input logic read,
    output logic [15:0] delay,
	 
	 input logic write,
	 input logic [15:0] writedata,
	 input logic [15:0] address
);
// faster, slower are push buttons

logic [3:0] delay_intern = 4'b1000;

assign delay = delay_intern;

always_ff @(posedge clk) begin
    if (reset)
        delay_intern <= 4'b1000;
    else if (faster && delay_intern != 4'b0001)
        delay_intern <= delay_intern - 1'b1; 
    else if (slower && delay_intern != 4'b1111)
        delay_intern <= delay_intern + 1'b1;
end

endmodule
