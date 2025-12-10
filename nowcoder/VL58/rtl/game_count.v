`timescale 1ns/1ns

module game_count
(
    input            rst_n, 
    input            clk, 	
    input      [9:0] money,
    input            set,
    input            boost,
    output reg [9:0] remain,
    output reg       yellow,
    output reg       red
);

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            remain <= 10'd0;
        end
        else begin
            if (set) begin
                remain <= remain + money;
            end
            else begin
                case (boost)
                    1'd0: remain <= remain - 10'd1;
                    1'd1: remain <= remain - 10'd2;
                    default: remain <= 10'd0;
                endcase
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            yellow <= 1'b0;
            red <= 1'b0;
        end
        else begin
            if (remain < 10'd10) begin
                if (remain == 10'd0) begin
                    red <= 1'b1;
                    yellow <= 1'b0;
                end
                else begin
                    red <= 1'b0; 
                    yellow <= 1'b1;                   
                end
            end
            else begin
                yellow <= 1'b0;
                red <= 1'b0;
            end
        end
    end
endmodule