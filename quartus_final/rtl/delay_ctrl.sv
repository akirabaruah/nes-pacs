module delay_ctrl (
    input clk,
    input faster,
    input slower,
	 
	 input reset,
	 
	 input read,
    output [15:0] delay,
	 
	 input write,
	 input [15:0] writedata
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