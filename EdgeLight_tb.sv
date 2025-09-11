`default_nettype none
`timescale 1ns / 1ps

module EdgeLight_tb;
    logic clk;
    logic reset;
    logic neighbor;
    logic turnOn, turnOff;
    logic lightOn;

    EdgeLight dut (
        .clk(clk),
        .reset(reset),
        .neighbor(neighbor),
        .turnOn(turnOn),
        .turnOff(turnOff),
        .lightOn(lightOn)
    );

    initial begin
        $dumpfile("EdgeLight_tb.vcd");
        $dumpvars(0, EdgeLight_tb);
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
        reset = 0; neighbor = 0; turnOn = 0; turnOff = 0;
        @(posedge clk);

        // 1) neighbor and turnOn
        reset = 0; neighbor = 1; turnOn = 1; turnOff = 0;
        @(posedge clk);
        #1 if (lightOn !== 1'b1) $error("T1: lightOn should be 1 when neighbor and turnOn are high.");
        wait_cycles(2);

        // 2) Reset when light is ON
        reset = 1; @(posedge clk);
        #1 reset = 0; @(posedge clk);
        if (lightOn !== 1'b0) $error("T2: lightOn should be 0 after reset.");
        wait_cycles(2);

        //3) turnOff when light is ON
        reset = 0; neighbor = 1; turnOn = 1; turnOff = 0; 
        @(posedge clk);
        #1 reset = 0; neighbor = 0; turnOn = 0; turnOff = 1;
        @(posedge clk);
        #1 if (lightOn !== 1'b0) $error("T3R1: lightOn should be 0 after turnOff is pressed and light is already on.");
        wait_cycles(2);

        //4) both turnOn and turnOff are pressed
        reset = 0; neighbor = 1; turnOn = 1; turnOff = 0;
        @(posedge clk);
        reset = 0; neighbor = 0; turnOn = 1; turnOff = 1;
        @(posedge clk);
        if (lightOn !== 1'b1) $error("T4R1: lightOn should stay 1 when both turnOn and turnOff are pressed while light is on.");
        wait_cycles(2);

        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge clk);
        $finish;
    end

endmodule // EdgeLight_tb