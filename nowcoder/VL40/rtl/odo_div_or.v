`timescale 1ns/1ns

module odo_div_or
   (
    input    wire  rst ,
    input    wire  clk_in,
    output   wire  clk_out7
    );

//*************code***********//
    reg [2:0] cnt_pos, cnt_neg;
    reg clk_pos, clk_neg;
    assign clk_out7 = clk_pos | clk_neg;

    always @(posedge clk_in or negedge rst) begin
        if (~rst) begin
            cnt_pos <= 3'd0;
            clk_pos <= 1'b0;
        end
        else begin
            cnt_pos <= cnt_pos + 3'd1;
            if (cnt_pos == 3'd4)
                clk_pos <= ~clk_pos;
            else if (cnt_pos == 3'd6) begin
                clk_pos <= 1'd0;
                cnt_pos <= 3'd0;
            end
        end
    end

    always @(negedge clk_in or negedge rst) begin
        if (~rst) begin
            cnt_neg <= 3'd0;
            clk_neg <= 1'b0;
        end
        else begin
            cnt_neg <= cnt_neg + 3'd1;
            if (cnt_neg == 3'd3)
                clk_neg <= ~clk_neg;
            else if (cnt_neg == 3'd6) begin
                clk_neg <= ~clk_neg;
                cnt_neg <= 3'd0;
            end
        end
    end
//*************code***********//
endmodule