`default_nettype none

module CenterLight (
    input logic clk,
    input logic reset,
    input logic L, R, NL, NR,
    input logic CE,
    output logic lightOn
);

    typedef enum logic {OFF, ON} state_t;
    state_t present_state = ON, next_state;

    always_ff @(posedge clk) begin
        if (reset)
            present_state <= ON;
        else if (CE)
            present_state <= next_state;
    end

    always_comb begin
        case (present_state)
            OFF:
                if ((~L & R & NL) | (~R & L & NR))
                    next_state = ON;
                else
                    next_state = OFF;
            ON:
                if (L^R)
                    next_state = OFF;
                else
                    next_state = ON;
            default: next_state = present_state;
        endcase
    end

    assign lightOn = (present_state == ON);

endmodule // CenterLight


        