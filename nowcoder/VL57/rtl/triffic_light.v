`timescale 1ns/1ns

module triffic_light
(
    input        clk, 
    input        rst_n, 
    input        pass_request,
    output reg [7:0] clock,
    output reg   red,
    output reg   yellow,
    output reg   green
);

    parameter RED    = 3'b001, 
              GREEN  = 3'b010, 
              YELLOW = 3'b100;

    reg [2 : 0] state, next_state;
    reg [7 : 0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= RED;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            RED:    next_state = (cnt == 0) ? GREEN  : RED;
            GREEN:  next_state = (cnt == 0) ? YELLOW : GREEN;
            YELLOW: next_state = (cnt == 0) ? RED    : YELLOW;
            default:next_state = RED;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 8'd10; 
        end else begin
            if (cnt == 0) begin
                case (next_state)
                    GREEN:  cnt <= 8'd60;
                    YELLOW: cnt <= 8'd5;
                    RED:    cnt <= 8'd10;
                endcase

            end else begin
                cnt <= cnt - 6'd1;
                // only GREEN responds to pass_request
                if (state == GREEN && pass_request && cnt > 8'd10)
                    cnt <= 8'd10;
            end
        end
    end

    always @(*) begin
        clock = cnt;
        case (state)
            GREEN: begin
                green  = 1'b1;
                yellow = 1'b0;
                red    = 1'b0;
            end
            YELLOW: begin
                green  = 1'b0;
                yellow = 1'b1;
                red    = 1'b0;
            end
            RED: begin
                green  = 1'b0;
                yellow = 1'b0;
                red    = 1'b1;
            end
            default: begin
                green  = 1'b0;
                yellow = 1'b0;
                red    = 1'b0;
            end
        endcase
    end

endmodule
