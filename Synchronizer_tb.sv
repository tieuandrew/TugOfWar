`timescale 1ns/1ps
`default_nettype none // Strictly enforce all nets to be declared

module Synchronizer_tb;
    logic clk, reset_synced, reset_raw, in, out, first_out;

    Synchronizer dut (
        .clk(clk),
        .reset(reset_synced),
        .in(in),
        .out(out),
        .first_out(first_out)
    );
    
    reset_sync u_rst_sync (
    .clk       (clk),
    .async_rst (reset_raw),
    .sync_rst  (reset_synced)
    );

    initial begin
        $dumpfile("Synchronizer_tb.vcd");           // name of the VCD file to write
        $dumpvars(0, Synchronizer_tb);    // dump EVERYTHING under this scope
    // Optionally: $dumpvars(1, dut); // or limit to the DUT hierarchy
    end

    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz clock --> 20 ns period via #10 ns half-period
    end

    // Helper wait function for cleaner testbench simulation
    task automatic wait_cycles(input int num_cycles); // Automatic for re-entrancy
        repeat (num_cycles) @(posedge clk);
    endtask

    initial begin
        
        // ---------- 0) Power-on: clean reset release ----------
        in = 0;
        reset_raw = 1;                  // assert raw reset
        // Deassert raw reset mid-cycle; reset_synced will release on next posedge
        reset_raw = 0;
        wait_cycles(2);               // 1st edge after deassert: synced reset still asserted last cycle, now 0
        if (reset_synced !== 1'b0) $error("reset_synced should be low after 1st edge post-deassert");
        @(posedge clk);

        wait_cycles(2); // Wait for two clock cycles

        // 1) Test input signal changes and observe output after two clock cycles
        in = 1; @(posedge clk); // Drive input high
        in = 0; @(posedge clk);

        // Expect out to rise two cycles after in rises
        if (out !== 1'b1) $error("OUT did not rise on 2nd edge after IN.");
        @(posedge clk); // Expect out to fall two cycles after in falls
        if (out !== 1'b0) $error("OUT did not fall two edges after IN.");

        wait_cycles(2); // Wait for two clock cycles

        // 3) Mid cycle input --> ONE CYCLE DELAY FOR MID CYCLE INPUT CHANGE
        #7 in = 1; // Change input mid-cycle
        wait_cycles(2);
        if (out !== 1'b0) $error("R1: OUT should be 0 on the 1st edge after IN rose.");
        in = 0;
        @(posedge clk); // Second clock edge --> Input into second DFF
        if (out !== 1'b1) $error("R2: OUT should be 1 on the 2nd edge after IN rose.");
        @(posedge clk); // Next clock edge --> Output should now reflect input
        if (out !== 1'b0) $error("R3: OUT should be 0 on the 2nd edge after IN fell");

        // 4) Mid cycle reset
        in = 1; wait_cycles(2); // Ensure input is stable high
        reset_raw = 1 ; // Assert reset mid-cycle
        #1 if (out !== 1'b0) $error("OUT did not clear immediately after mid-cycle reset."); // Need small delay to allow async reset to propagate
        reset_raw = 0;
        wait(reset_synced == 1'b0); // Wait until synced reset deasserts --> Two clock cycles
        @(posedge clk); //DFF's sample reset_synced low
        //After reset, out should remain low for two clock cycles before reflecting in = 1 --> DFF propogation delay
        wait_cycles(2);
        if (out!== 1'b1) $error("OUT did not rise on the 2nd edge after mid-cycle reset.");
        in = 0;
        wait_cycles(2); // Wait for two clock cycles
        $finish; // End simulation
    end
endmodule // synchronizer_tb

//$display("[%0t] in=%0b rs=%0b, rr=%0b out=%0b, first_out=%0b", $time, in, reset_synced, reset_raw, out, first_out);