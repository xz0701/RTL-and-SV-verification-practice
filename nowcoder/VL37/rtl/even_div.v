`timescale 1ns/1ns

module even_div
    (
    input     wire rst ,
    input     wire clk_in,
    output    wire clk_out2,
    output    wire clk_out4,
    output    wire clk_out8
    );
//*************code***********//
    reg cnt_2;
    reg [1:0] cnt_4;
    reg [2:0] cnt_8;
    reg clk_2, clk_4, clk_8;

    assign clk_out2 = clk_2;
    assign clk_out4 = clk_4;
    assign clk_out8 = clk_8;
    
    always @(posedge clk_in or negedge rst) begin
        if (~rst) begin
            cnt_2 <= 1'b0;
            clk_2 <= 1'b0;
        end
        else begin
            cnt_2 <= cnt_2 + 1'd1;
            if (cnt_2 == 1'd0) begin
                clk_2 <= ~clk_2;
            end
            else if (cnt_2 == 1'd1) begin
                clk_2 <= ~clk_2;
                cnt_2 <= 1'b0;
            end
        end
    end

    always @(posedge clk_in or negedge rst) begin
        if (~rst) begin
            cnt_4 <= 2'b0;
            clk_4 <= 1'b0;
        end
        else begin
            cnt_4 <= cnt_4 + 2'd1;
            if (cnt_4 == 2'd0) begin
                clk_4 <= ~clk_4;
            end
            else if (cnt_4 == 2'd2) begin
                clk_4 <= ~clk_4;
            end
            else if (cnt_4 == 2'd3) begin
                cnt_4 <= 2'd0;
            end
        end
    end

    always @(posedge clk_in or negedge rst) begin
        if (~rst) begin
            cnt_8 <= 3'd0;
            clk_8 <= 1'b0;
        end
        else begin
            cnt_8 <= cnt_8 + 2'd1;
            if (cnt_8 == 3'd0) begin
                clk_8 <= ~clk_8;
            end
            else if (cnt_8 == 3'd4) begin
                clk_8 <= ~clk_8;
            end
            else if (cnt_8 == 3'd7) begin
                cnt_8 <= 3'd0;
            end
        end
    end

//*************code***********//
endmodule