`timescale 1ns/1ns

module count_module(
	input clk,
	input rst_n,
	input mode,
	output reg [3:0]number,
	output reg zero
);
	reg [3 : 0] num; // has to stall 1 cycle;
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			number <= 4'd0;
			zero <= 1'b0;
			num <= 4'd0;
		end
		else begin
			zero <= (num == 4'd0);
			number <= num;
			case (mode)
				1'b0: num <= (num == 4'd0) ? 4'd9 : num - 4'd1;
				1'b1: num <= (num == 4'd9) ? 4'd0 : num + 4'd1;
				default: begin
					number <= 4'b0;
					zero <= 1'b0;
				end
			endcase
		end
	end
endmodule