`default_nettype none

module TugOfWar (
    input logic [9:0] SW, // Switches (SW[9:0]) inclusive
    input logic [3:0] KEY, // Keys (KEY[3:0]) Active low
    input logic clk, // Divided clock input from top module 
    input logic CE, // Clock enable from top module
    output logic [9:1] LEDR, // LEDs (LEDR[9:1]
    output logic [6:0] HEX5, HEX0 // 7-segment display
    );
    
    // Computer (right) instantiation
    logic right;
    logic [8:0] sum_out;
    logic [8:0] LFSR_out;

    LFSR computer (.clk(clk), .reset(SW[9]), .CE(CE), .out(LFSR_out));
    NineBitAdder adder (.A(SW[8:0]), .B(LFSR_out), .C(sum_out), .Cout(right));

    logic l_sync;
    logic l_button;
    
    // Synchronize button presses
    Synchronizer sync_left (
        .clk(clk),
        .reset(SW[9]),
        .in(~KEY[3]), // Left button (KEY[3]) active low
        .out(l_sync)
    );

    // Detect edge press for each button 
    EdgeDetector ED_left (
        .clk(clk),
        .reset(SW[9]),
        .pressed(l_sync),
        .out(l_button)
    );
    
    logic l_button_g, r_button_g;
    assign r_button_g = right & CE;
    
    // Stretch l_button_g to high until next CE tick
    always_ff @(posedge clk) begin
        if (SW[9])           
            l_button_g <= 1'b0;
        else if (l_button) 
            l_button_g <= 1'b1;  // set on the 20 ns pulse
        else if (CE)        
            l_button_g <= 1'b0;  // clear on next CE tick
        end
    
    // Sync reset condition to CE clock
    logic res;
    always @(posedge clk) begin
        if (SW[9] | (r_button_g & ~l_button_g & LEDR[1]) | (l_button_g & ~r_button_g & LEDR[9])) // Reset lights when there's a winner or hard reset)
            res <= 1'b1;
        else if (CE)
            res <= 1'b0;
    end
    
    EdgeLight L9 (.clk(clk), .reset(res), .neighbor(LEDR[8]), .turnOn(l_button_g), .turnOff(r_button_g), .CE(CE), .lightOn(LEDR[9]));
    NormalLight L8 (.clk(clk), .reset(res), .L(l_button_g), .R(r_button_g), .NL(LEDR[9]), .NR(LEDR[7]), .CE(CE), .lightOn(LEDR[8]));
    NormalLight L7 (.clk(clk), .reset(res), .L(l_button_g), .R(r_button_g), .NL(LEDR[8]), .NR(LEDR[6]), .CE(CE), .lightOn(LEDR[7]));
    NormalLight L6 (.clk(clk), .reset(res), .L(l_button_g), .R(r_button_g), .NL(LEDR[7]), .NR(LEDR[5]), .CE(CE), .lightOn(LEDR[6]));
    CenterLight L5 (.clk(clk), .reset(res), .L(l_button_g), .R(r_button_g), .NL(LEDR[6]), .NR(LEDR[4]), .CE(CE), .lightOn(LEDR[5]));
    NormalLight L4 (.clk(clk), .reset(res), .L(l_button_g), .R(r_button_g), .NL(LEDR[5]), .NR(LEDR[3]), .CE(CE), .lightOn(LEDR[4]));
    NormalLight L3 (.clk(clk), .reset(res), .L(l_button_g), .R(r_button_g), .NL(LEDR[4]), .NR(LEDR[2]), .CE(CE), .lightOn(LEDR[3]));
    NormalLight L2 (.clk(clk), .reset(res), .L(l_button_g), .R(r_button_g), .NL(LEDR[3]), .NR(LEDR[1]), .CE(CE), .lightOn(LEDR[2]));
    EdgeLight L1 (.clk(clk), .reset(res), .neighbor(LEDR[2]), .turnOn(r_button_g), .turnOff(l_button_g), .CE(CE), .lightOn(LEDR[1]));

    // inputting l_button unsynced with clock enable because win condition reads on 50 Mhz clock, 
    // so win condition would be high for multiple cycles if using CE synced input 
    // (2 score per win condition instead of 1)
    Counter leftCounter (.clk(clk), .reset(SW[9]), .win(l_button & ~r_button_g & LEDR[9]), .hex(HEX5)); // Counters only reset on hard reset
    Counter rightCounter (.clk(clk), .reset(SW[9]), .win(r_button_g & ~l_button_g & LEDR[1]), .hex(HEX0));

endmodule // TugOfWar
