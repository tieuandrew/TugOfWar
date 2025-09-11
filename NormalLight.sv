`default_nettype none

// This module controls a light with a simple state machine based on button presses and neighboring states.
module NormalLight (
    input logic clk, reset,

    // L, R: indicate key presses (left and right)
    // NL, NR: indicate whether neighboring lights are on
    input logic L, R, NL, NR,

    // lightOn: output that controls the light's status (on/off)
    output logic lightOn
    );

    // State definition for the light: OFF or ON
    typedef enum logic {OFF, ON} state_t;
    state_t present_state = OFF, next_state;

    // Combinational logic for next state calculations:
    // - When OFF: turn ON if neighbor light conditions and key presses are met.
    // - When ON: turn OFF if exactly one of L or R is pressed.
    always_comb
        case (present_state)
                OFF: 
                    if ((NL & R & ~L) | (NR & L & ~R))
                        next_state = ON;
                    else
                        next_state = OFF;
                ON: 
                    if (L ^ R) begin
                        next_state = OFF;
                    end else begin
                        next_state = ON;
                    end

                default: next_state = present_state;  // Defaults to hold state if undefined
        endcase
    
    assign lightOn = (present_state == ON);

    // Sequential logic updating the state on rising edge 
    always_ff @(posedge clk) begin
        if (reset)
                present_state <= OFF;  // Reset the state to OFF
        else
                present_state <= next_state;  // Transition to the next state
    end

endmodule  // normalLight