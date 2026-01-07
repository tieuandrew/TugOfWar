`default_nettype none

module Counter (
    input logic clk,
    input logic reset,
    input logic win,
    output logic [6:0] hex
);

    logic [2:0] score;

    always_ff @(posedge clk) begin
        if (reset)
            score <= 3'b000;
        else if (win & score != 3'b111) // Only increment if score is less than 7
            score <= score + 1'b1;
    end

    always_comb begin
        case (score)
            3'b000: hex = 7'b1000000; // 0
            3'b001: hex = 7'b1111001; // 1
            3'b010: hex = 7'b0100100; // 2
            3'b011: hex = 7'b0110000; // 3
            3'b100: hex = 7'b0011001; // 4
            3'b101: hex = 7'b0010010; // 5
            3'b110: hex = 7'b0000010; // 6
            3'b111: hex = 7'b1111000; // 7
            default: hex = 7'b1111111; // Blank
        endcase
    end
endmodule // Counter
