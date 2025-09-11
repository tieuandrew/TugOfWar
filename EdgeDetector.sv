`default_nettype none

module EdgeDetector (
    input logic clk,
    input logic reset,
    input logic pressed,
    output logic out);

    // Define an enumerated type 'state' with two possible values: ZERO and ONE.
    typedef enum logic {ZERO, ONE} state_t;
    state_t current_state, next_state;

    // CASE STATEMENT VERSION
    // always_comb begin
    //     case (current_state)
    //         ZERO: if (pressed) next_state = ONE;
    //                 else next_state = ZERO;
    //         ONE: if (pressed) next_state = ONE;
    //                 else next_state = ZERO;
    //     endcase
    // end

    assign next_state = state_t'(pressed ? ONE : ZERO); // If 'pressed' is high, choose ONE; otherwise, choose ZERO.

    // Update the state on the rising edge of 'clk' or reset to ZERO if 'reset' is high.
    always_ff @(posedge clk) begin
        if (reset)
            current_state <= ZERO; // On reset, set current_state to ZERO.
        else
            current_state <= next_state; // Otherwise, update current_state with the computed next_state.
    end

    // Generate the output: it is high when 'pressed' is high and the current state is ZERO.
    assign out = pressed && (current_state == ZERO);

endmodule // EdgeDetector