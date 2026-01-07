`default_nettype none

module NineBitAdder (
    input  logic [8:0] A,
    input  logic [8:0] B,
    output logic [8:0] C,
    output logic       Cout
);

    logic [9:0] sum;

    assign sum  = A + B;
    assign C    = sum[8:0];
    assign Cout = sum[9];

endmodule // NineBitAdder
