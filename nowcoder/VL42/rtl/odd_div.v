`timescale 1ns/1ns

module odd_div (    
    input     wire rst ,
    input     wire clk_in,
    output    wire clk_out5
);
    reg [2:0] cnt_pos, cnt_neg;
    reg clk_pos, clk_neg;

    assign clk_out5 = clk_pos | clk_neg;

    always @(posedge clk_in or negedge rst) begin
        if (~rst) begin
            cnt_pos <= 3'd0;
            clk_pos <= 1'b0;
        end
        else begin
            cnt_pos <= cnt_pos + 3'd1;
            if (cnt_pos == 3'd0) begin
                clk_pos <= ~clk_pos;
            end
            else if (cnt_pos == 3'd2) begin
                clk_pos <= ~clk_pos;
            end
            else if (cnt_pos == 3'd4) begin
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
            if (cnt_neg == 3'd1) begin
                clk_neg <= ~clk_neg;
            end
            else if (cnt_neg == 3'd2) begin
                clk_neg <= ~clk_neg;
            end
            else if (cnt_neg == 3'd4) begin
                cnt_neg <= 3'd0;
            end
        end
    end

endmodule