`default_nettype none

module TugOfWar (
    input logic [9:0] SW, // Switches (SW[9:0]) inclusive
    input logic [3:0] KEY, // Keys (KEY[3:0]) Active low
    input logic CLOCK_50, // 50 MHz clock
    output logic [9:1] LEDR, // LEDs (LEDR[9:1]
    output logic [6:0] HEX0 // 7-segment display (HEX0
    );

    logic clk;
    assign clk = CLOCK_50;

    logic reset;
    assign reset = SW[9];
    logic l_sync, r_sync;
    logic l_button, r_button;
    
    // Synchronize button presses
    Synchronizer sync_left (
        .clk(clk),
        .reset(reset),
        .in(~KEY[3]), // Left button (KEY[3]) active low
        .out(l_sync)
    );
    Synchronizer sync_right (
        .clk(clk),
        .reset(reset),
        .in(~KEY[0]), // Right button (KEY[0]) active low
        .out(r_sync)
    );

    // Detect edge press for each button 
    EdgeDetector ED_left (
        .clk(clk),
        .reset(reset),
        .pressed(l_sync),
        .out(l_button)
    );

    EdgeDetector ED_right (
        .clk(clk),
        .reset(reset),
        .pressed(r_sync),
        .out(r_button)
    );

    logic game_over;

    Victory v (.clk(clk), .reset(reset), .Llight(LEDR[9]), .Rlight(LEDR[1]), .L(l_button), .R(r_button), .hex(HEX0), .game_over(game_over));

    logic l_button_g, r_button_g;
    assign l_button_g = l_button & ~game_over; // Freeze buttons when game is over
    assign r_button_g = r_button & ~game_over;
    
    EdgeLight L9 (.clk(clk), .reset(reset), .neighbor(LEDR[8]), .turnOn(l_button_g), .turnOff(r_button_g), .lightOn(LEDR[9]));
    NormalLight L8 (.clk(clk), .reset(reset), .L(l_button_g), .R(r_button_g), .NL(LEDR[9]), .NR(LEDR[7]), .lightOn(LEDR[8]));
    NormalLight L7 (.clk(clk), .reset(reset), .L(l_button_g), .R(r_button_g), .NL(LEDR[8]), .NR(LEDR[6]), .lightOn(LEDR[7]));
    NormalLight L6 (.clk(clk), .reset(reset), .L(l_button_g), .R(r_button_g), .NL(LEDR[7]), .NR(LEDR[5]), .lightOn(LEDR[6]));
    CenterLight L5 (.clk(clk), .reset(reset), .L(l_button_g), .R(r_button_g), .NL(LEDR[6]), .NR(LEDR[4]), .lightOn(LEDR[5]));
    NormalLight L4 (.clk(clk), .reset(reset), .L(l_button_g), .R(r_button_g), .NL(LEDR[5]), .NR(LEDR[3]), .lightOn(LEDR[4]));
    NormalLight L3 (.clk(clk), .reset(reset), .L(l_button_g), .R(r_button_g), .NL(LEDR[4]), .NR(LEDR[2]), .lightOn(LEDR[3]));
    NormalLight L2 (.clk(clk), .reset(reset), .L(l_button_g), .R(r_button_g), .NL(LEDR[3]), .NR(LEDR[1]), .lightOn(LEDR[2]));
    EdgeLight L1 (.clk(clk), .reset(reset), .neighbor(LEDR[2]), .turnOn(r_button_g), .turnOff(l_button_g), .lightOn(LEDR[1]));

endmodule // TugOfWar
