`timescale 1ns/1ns

module div_M_N(
 input  wire clk_in,
 input  wire rst,
 output wire clk_out
);
    parameter M_N = 8'd87; 
    parameter c89 = 8'd24; 
    parameter div_e = 5'd8; 
    parameter div_o = 5'd9; 

    reg [4:0] cnt_8, cnt_9;
    reg [7:0] cnt;
    reg switch;
    reg clk_8, clk_9;

    assign clk_out = clk_8 | clk_9;

    always @(posedge clk_in or negedge rst) begin
        if (~rst) begin
            cnt <= 8'd0;
            switch <= 1'b0;
        end
        else begin
            cnt <= cnt + 8'd1;
            if (cnt == c89 - 8'd1) begin
                switch <= 1'b1;
            end
            else if (cnt == M_N - 8'd1) begin
                switch <= 1'b0;
                cnt <= 8'd0;
            end
        end
    end

    always @(posedge clk_in or negedge rst) begin
        if (~rst) begin
            cnt_8 <= 5'd0;
            cnt_9 <= 5'd0;
            clk_8 <= 1'b0;
            clk_9 <= 1'b0;
        end
        else begin
            if (~switch) begin
                cnt_8 <= cnt_8 + 5'd1;
                if (cnt_8 == div_e - 5'd1) begin
                    cnt_8 <= 5'd0;
                end
                else if (cnt_8 == 5'd0) begin
                    clk_8 <= ~clk_8;
                end
                else if (cnt_8 == (div_e >> 1)) begin
                    clk_8 <= ~clk_8;
                end
            end
            else begin
                cnt_9 <= cnt_9 + 5'd1;
                if (cnt_9 == div_o - 5'd1) begin
                    cnt_9 <= 5'd0;
                end
                else if (cnt_9 == 5'd0) begin
                    clk_9 <= ~clk_9;
                end
                else if (cnt_9 == (div_o >> 1)) begin
                    clk_9 <= ~clk_9;
                end
            end
        end
    end

endmodule