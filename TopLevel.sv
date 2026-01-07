`default_nettype  none

module TopLevel (
    input logic CLOCK_50, // 50 MHz clock
    input logic [3:0] KEY, // Keys (KEY[3:0]) Active low
    input logic [9:0] SW, // Switches (SW[9:0
    output logic [9:1] LEDR, // LEDs (LEDR[9:1]
    output logic [6:0] HEX0, HEX5 // 7-segment display
    );

    localparam int unsigned DIV_FACTOR = 19; // 2^DIV_FACTOR num of cycles
    logic CE; // Clock enable

    ClockDivider #(.DIV(DIV_FACTOR)) u_clock (.clk_in(CLOCK_50), .reset(SW[9]), .clk_enable(CE));
    
    TugOfWar u_tug (.SW(SW), .KEY(KEY), .clk(CLOCK_50), .CE(CE), .LEDR(LEDR), .HEX0(HEX0), .HEX5(HEX5));

endmodule // TopLevel





