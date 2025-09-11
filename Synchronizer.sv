`default_nettype none // Strictly enforce all nets to be declared

module Synchronizer(
    input logic clk, reset, in,
    output logic out, first_out
);

    // logic first_out; // output of the first DFF

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            first_out <= 1'b0; // Reset the first flip-flop output
        else
            first_out <= in; // Capture the input
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            out <= 1'b0; // Reset the output
        else
            out <= first_out; // Capture the output of the first flip-flop
    end

endmodule // synchronizer