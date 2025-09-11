`timescale 1ns / 1ps
`default_nettype none

module CenterLight_tb;
    logic clk;
    logic reset;
    logic L, R, NL, NR;
    logic lightOn;

    CenterLight dut (
        .clk(clk),
        .reset(reset),
        .L(L),
        .R(R),
        .NL(NL),
        .NR(NR),
        .lightOn(lightOn)
    );

    initial begin
        $dumpfile("CenterLight_tb.vcd");
        $dumpvars(0, CenterLight_tb);
    end

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz clock
    end

    // Helper wait function
    task automatic wait_cycles(input int num_cycles);
        repeat (num_cycles) @(posedge clk);
    endtask

    initial begin
        reset = 0; L = 0; R = 0; NL = 0; NR = 0;
        @(posedge clk);

        // 1) Reset ON
        reset = 1; @(posedge clk);
        reset = 0; @(posedge clk);
        if (lightOn !== 1'b1) $error("T1: lightOn should be 1 after reset.");
        wait_cycles(2);

        // 2) NL and R
        NL = 1; NR = 0; L = 0; R = 1; @(posedge clk);
        if (lightOn !== 1'b1) $error("T2R1: lightOn did not go high after NL and R went high.");
        wait_cycles(2);

        // 3) R goes high while light is on
        NL = 0; NR = 0; L = 0; R = 1; @(posedge clk);
        if (lightOn !== 1'b0) $error("T3R1: lightOn did not go low after R went high while light was on.");
        wait_cycles(2);


        // 4) NR and L
        #5; NL <= 0; NR <= 1; L <= 1; R <= 0; #1; @(posedge clk); #1;
        if (lightOn !== 1'b1) $error("T4R1: lightOn did not go high after NR and L went high.");
        #5; L<=0; R<= 0; 
        wait_cycles(2);


        // 5) L and R both high while light is on
        #5; NL = 0; NR = 0; L = 1; R = 1; #1; @(posedge clk);
        
        if (lightOn !== 1'b1) $error("T5R1: lightOn did not stay high after L and R both went high.");
        wait_cycles(2);

        // 6) L goes high while light is on
        L <= 1; R <= 0; wait_cycles(2);
        if (lightOn !== 1'b0) $error("T6R1: lightOn did not go low after L went high while light was on.");
        wait_cycles(2);

        // 7) L and R both high while neighbor is high
        NL = 1; NR = 0; L = 1; R = 1; @(posedge clk);
        if (lightOn !== 1'b0) $error("T7R1: lightOn did not stay low after L and R both went high with NL high.");
        NL = 0; NR = 1; L = 1; R = 1; @(posedge clk);
        if (lightOn !== 1'b0) $error("T7R2: lightOn did not stay low after L and R both went high with NR high.");
        $finish;
    end
endmodule // CneterLight_tb
