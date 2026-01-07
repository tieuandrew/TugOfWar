`default_nettype none

module LFSR (
    input  logic clk,
    input  logic reset,
    input logic CE,
    output logic [8:0] out
);
    
    assign new_bit = out[8] ~^ out[4]; // XNOR feedback based on table

    always_ff @(posedge clk) begin
        if (reset)
            out <= 9'b0;
        else if (CE) begin
            out <= {out[7:0], new_bit};
        end
    end
endmodule // LFSR