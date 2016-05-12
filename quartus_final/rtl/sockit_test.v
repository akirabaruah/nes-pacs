module sockit_test (
    input CLOCK_50,
    input [3:0] KEY,
    output [3:0] LED,
	 
	 output [12:0] hps_memory_mem_a,
    output [2:0]  hps_memory_mem_ba,
    output        hps_memory_mem_ck,
    output        hps_memory_mem_ck_n,
    output        hps_memory_mem_cke,
    output        hps_memory_mem_cs_n,
    output        hps_memory_mem_ras_n,
    output        hps_memory_mem_cas_n,
    output        hps_memory_mem_we_n,
    output        hps_memory_mem_reset_n,
    inout  [7:0] hps_memory_mem_dq,
    inout		  hps_memory_mem_dqs,
    inout		  hps_memory_mem_dqs_n,
    output        hps_memory_mem_odt,
    output		  hps_memory_mem_dm,
    input         hps_memory_oct_rzqin
);

// internal signals
wire [3:0] key_os;
wire [3:0] delay;
wire main_clk = CLOCK_50;

assign delay[1] = 0;
assign delay[2] = 0;
//wire test_out;

oneshot os (
    .clk (main_clk), // port mappings
    .edge_sig (KEY),
    .level_sig (key_os)
);


soc_system soc (
    .delay_ctrl_slower (delay[0]),
    .delay_ctrl_faster (key_os[1]),
    .memory_mem_a        (hps_memory_mem_a),
    .memory_mem_ba       (hps_memory_mem_ba),
    .memory_mem_ck       (hps_memory_mem_ck),
    .memory_mem_ck_n     (hps_memory_mem_ck_n),
    .memory_mem_cke      (hps_memory_mem_cke),
    .memory_mem_cs_n     (hps_memory_mem_cs_n),
    .memory_mem_ras_n    (hps_memory_mem_ras_n),
    .memory_mem_cas_n    (hps_memory_mem_cas_n),
    .memory_mem_we_n     (hps_memory_mem_we_n),
    .memory_mem_reset_n  (hps_memory_mem_reset_n),
    .memory_mem_dq       (hps_memory_mem_dq),
    .memory_mem_dqs      (hps_memory_mem_dqs),
    .memory_mem_dqs_n    (hps_memory_mem_dqs_n),
    .memory_mem_odt      (hps_memory_mem_odt),
    .memory_mem_dm       (hps_memory_mem_dm),
    .memory_oct_rzqin    (hps_memory_oct_rzqin),

    .clk_clk (main_clk),
    .reset_reset_n (!key_os[3])
);

blinker b (
    .clk (main_clk),
    .delay (delay),
    .led (LED),
    .reset (key_os[3]),
    .pause (key_os[2])
);
endmodule
