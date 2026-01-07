`default_nettype none
// Use as a clock enable for actual clock to avoid timing issues on hardware (DFF's canot change insantaenously)
module ClockDivider #(
    parameter int unsigned DIV = 16 // Enable every 2^DIV
) (
    input logic clk_in,
    input logic reset,
    output logic clk_enable
    );

    logic [DIV-1:0] counter; // counter wide enough to allow for CE up to DIV cycles
    // Could also use arithmetic to minimize DFF's but this is more straightforward
    always_ff @(posedge clk_in) begin
        if (reset) begin
            counter <= '0;
            clk_enable <= 1'b0;
        end else begin
            counter <= counter + 1'b1;
            clk_enable <= (counter == 0); // Enable for one cycle every 2^DIV cycles
        end
    end
endmodule // ClockDivider
