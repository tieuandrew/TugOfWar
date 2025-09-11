`default_nettype none

module Victory (
    input logic clk,
    input logic reset,
    input logic Llight, Rlight,
    input logic L, R,
    output logic [6:0] hex,
    output logic game_over // Freezes the game when there's a winner
    );

    typedef enum logic [1:0] {OFF, left_win, right_win} state_t;
    state_t present_state = OFF, next_state;

    always_ff @(posedge clk) begin
        if (reset)
            present_state <= OFF;
        else
            present_state <= next_state;
    end

    always_comb begin
        next_state = present_state;
        hex = 7'b1111111;
        game_over = 1'b0;
        case (present_state)
            OFF: begin
                if (Llight &~Rlight & L & ~R)
                    next_state = left_win;
                else if (Rlight & ~Llight & R & ~L)
                    next_state = right_win;
            end
            left_win: begin
                hex = 7'b1111001; // Display '1'
                next_state = left_win;
                game_over = 1'b1;
            end
            right_win: begin
                hex = 7'b0100100; // Display '2'
                next_state = right_win;
                game_over = 1'b1;
            end
            default: next_state = OFF;
        endcase
    end
endmodule // Victory