`default_nettype none
`timescale 1ns/1ps

module EdgeDetector_tb;

    logic clk;
    logic reset;
    logic pressed;
    logic out;

    // Instantiate the EdgeDetector module
    EdgeDetector dut (
        .clk(clk),
        .reset(reset),
        .pressed(pressed),
        .out(out)
    );
    
    initial begin
        $dumpfile("EdgeDetector_tb.vcd");           // name of the VCD file to write
        $dumpvars(0, EdgeDetector_tb);    // dump EVERYTHING under this scope
    // Optionally: $dumpvars(1, dut); // or limit to the DUT hierarchy
    end

    // Clock generation: 50 MHz clock --> 20 ns period via #10 ns half-period
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // Toggle clock every 10 ns
    end

    // Helper wait function for cleaner testbench
    task automatic wait_cycles(input int num_cycles);
        repeat (num_cycles) @(posedge clk);
    endtask

    initial begin
        pressed = 0;
        reset = 0;
        @(posedge clk);

        // 1) Reset ON
        pressed = 1; @(posedge clk);
        reset = 1; @(posedge clk);
        if (out !== 1'b0) $error("T1: OUT should be 0 after reset.");
        reset = 0; @(posedge clk);
        pressed = 0; @(posedge clk);
        wait_cycles(2);

        // 2) Pressed ON, two cycles, then OFF
        pressed = 1; @(posedge clk);
        if (out !== 1'b1) $error("T2R1: OUT did not go high after pressed went high.");
        @(posedge clk);
        if (out !== 1'b0) $error("T2R2: OUT did not go low after 1 clock cycle.");
        pressed = 0; @(posedge clk);
        if (out !== 1'b0) $error("T2R3: OUT should stay low after 1 clock cycle.");
        wait_cycles(2);

        // 3) Pressed ON then OFF
        pressed = 1; @(posedge clk);
        if (out !== 1'b1) $error("T3R1: OUT did not go high after pressed went high.");
        pressed = 0; @(posedge clk);
        if (out !== 1'b0) $error("T3R2: OUT did not go low ater 1 clock cycle.");
        $finish;
    end
endmodule