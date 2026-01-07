`timescale 1ns/1ps
`default_nettype none

module LFSR_tb;

    logic clk = 0;
    logic reset = 1;
    logic enable = 0;
    logic [8:0] state;

    LFSR dut (
        .clk    (clk),
        .reset  (reset),
        .enable (enable),
        .state  (state)
    );

    always #5 clk = ~clk;

    bit visited_map [0:511];
    int cycle_count = 0;
    int unique_states = 0;
    int key;
    logic [8:0] initial_state;

    initial begin
        for (int i = 0; i < 512; i++) begin
            visited_map[i] = 1'b0;
        end

        $display("--- LFSR period check starting ---");
        repeat (2) @(posedge clk);
        reset = 0;
        enable = 1;

        initial_state = state;
        key = state;
        visited_map[key] = 1'b1;
        unique_states = 1;
        $display("Seed state: %b", state);

        forever begin
            @(posedge clk);
            #1; // wait for nonblocking state update
            cycle_count++;

            key = state;
            if (visited_map[key]) begin
                $display("State %b repeated after %0d cycles (unique states seen: %0d)", state, cycle_count, unique_states);
                if (state == initial_state && cycle_count == 511 && unique_states == 511) begin
                    $display("PASS: 9-bit LFSR produced maximal period of 511 unique states before repeating the seed.");
                    $finish;
                end else begin
                    $fatal(1, "Unexpected repetition detected. Test failed.");
                end
            end else begin
                visited_map[key] = 1'b1;
                unique_states++;
                if (state == 9'b0) begin
                    $fatal(1, "LFSR entered the all-zero lock-up state.");
                end

                if ((cycle_count % 64) == 0)
                    $display("Checkpoint: %0d cycles with no repeats. Current state: %b", cycle_count, state);

                if (cycle_count > 512) begin
                    $fatal(1, "Exceeded expected cycle length without repetition.");
                end
            end
        end
    end

endmodule
