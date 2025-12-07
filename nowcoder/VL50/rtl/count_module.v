`timescale 1ns/1ns

module count_module(
	input clk,
	input rst_n,

    output reg [5:0]second,
    output reg [5:0]minute
);
	reg flag;

	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			second <= 6'd0;
			minute <= 6'd0;
			flag <= 1'b0;
		end
		else begin
			if (~flag) begin
				second <= second + 6'd1;
				if (second == 6'd60) begin
					second <= 6'd1;
					minute <= minute + 6'd1;
					if (minute == 6'd60) begin
						flag <= 1'b1;
					end
					else begin
						flag <= 1'b0;
					end
				end
			end
		end
	end
	
endmodule