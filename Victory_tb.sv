`timescale 1ns / 1ps
`default_nettype none

module Victory_tb; 
    logic clk;
    logic reset;
    logic L, R, Llight, Rlight;
    logic left_win, right_win;
    logic [6:0] hex;

    Victory dut (
        .clk(clk),
        .reset(reset),
        .L(L),
        .R(R),
        .Llight(Llight),
        .Rlight(Rlight),
        .hex(hex)
    );

    initial begin
        $dumpfile("Victory_tb.vcd");
        $dumpvars(0, Victory_tb);
    end

    // Clock generation
    initial clk = 0;
    always #10 clk = ~clk; // 50 MHz clock

    // Helper wait function
    task automatic wait_cycles(input int num_cycles);
        repeat (num_cycles) @(posedge clk);
    endtask

    initial begin
        reset = 0; L = 0; R = 0; Llight = 0; Rlight = 0;
        @(posedge clk);

        // 1) Left win
        reset = 0; L = 1; R = 0; Llight = 1; Rlight = 0;
        @(posedge clk);
        #1 L = 0; Llight = 0; R = 1; Rlight = 1; // figure out how to check for continuous left victory
        @(posedge clk);
        #1 reset = 1; L = 0; R = 0; Llight = 0; Rlight = 0; @(posedge clk);
        #1 reset = 0; @(posedge clk);

        // 2) Right win
        L = 0; R = 1; Llight = 0; Rlight = 1;
        @(posedge clk); // figure out how to check for continuous right victory
        #1 L = 1; R = 0; Llight = 1; Rlight = 0;
        @(posedge clk);
        #1 reset = 1; L = 0; R = 0; Llight = 0; Rlight = 0; @(posedge clk);
        #1 reset = 0; @(posedge clk);

        // 3) No win
        L = 0; R = 0; Llight = 0; Rlight = 0; @(posedge clk);
        #1 L = 1; R = 1; Llight = 0; Rlight = 1; @(posedge clk); // check for win

        L = 0; R = 0; Llight = 0; Rlight = 0; @(posedge clk);
        #1 L = 1; R = 1; Llight = 1; Rlight = 0; @(posedge clk); // check for win

        L = 0; R = 0; Llight = 0; Rlight = 0; @(posedge clk);
        #1 L = 1; Rlight = 1; @(posedge clk); // check for win

        L = 0; Rlight = 0; @(posedge clk);
        #1 R = 1; Llight = 1; @(posedge clk); // check for win

        R = 0; Llight = 0; @(posedge clk);

        reset = 1; @(posedge clk);
        reset = 0; @(posedge clk);
        $finish;
    end
endmodule // Victory_tb