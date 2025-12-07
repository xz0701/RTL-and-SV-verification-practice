`timescale 1ns/1ns
// The answer on nowcoder is wrong!
module count_module(
	input clk,
	input rst_n,
	input set,
	input [3:0] set_num,
	output reg [3:0]number,
	output reg zero
);

	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			number <= 4'b0;
			zero <= 1'b0;
		end
		else begin
			zero <= (number == 4'd0);
			if (set) begin
				number <= set_num;
			end
			else begin
				number <= number + 4'd1;
			end
		end
	end
endmodule