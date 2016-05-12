module oneshot (
    input clk,
    input [3:0] edge_sig, // signal from keys
    output [3:0] level_sig // output for control signals
);

logic [3:0] cur_value;
logic [3:0] last_value;

// key signals: 0 when pressed, 1 when unpressed
assign level_sig = ~cur_value & last_value;

always_ff @(posedge clk) begin
    cur_value <= edge_sig; // <= values from previous clock
    last_value <= cur_value;
end

endmodule