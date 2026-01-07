`default_nettype none

module EdgeLight (
    input logic clk,
    input logic reset,
    input logic CE,
    input logic neighbor,
    input logic turnOn, turnOff,
    output logic lightOn
);

    typedef enum logic {OFF, ON} state_t;
    state_t present_state = OFF, next_state; // Initialize present_state to OFF

    always_ff @(posedge clk) begin
        if (reset)
            present_state <= OFF; // On reset, set present_state to OFF
        else if (CE)
            present_state <= next_state; // Update present_state with next_state
    end

    always_comb
        case (present_state)
                OFF:
                    if (neighbor & turnOn & ~turnOff)
                        next_state = ON;
                    else
                        next_state = OFF;
                ON:
                    if (turnOff & ~turnOn)
                        next_state = OFF;
                    else
                        next_state = ON;
                        
                default: next_state = present_state;
        endcase

    assign lightOn = (present_state == ON);

endmodule // EdgeLight