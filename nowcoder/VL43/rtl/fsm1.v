`timescale 1ns/1ns

module fsm1(
	input wire clk  ,
	input wire rst  ,
	input wire data ,
	output reg flag
);
	parameter S0 = 4'b0001,
			  S1 = 4'b0010,
			  S2 = 4'b0100,
			  S3 = 4'b1000;

	reg [3:0] state, next_state;

	always @(posedge clk or negedge rst) begin
		if (~rst) 
			state <= S0;
		else
			state <= next_state;
	end

	always @(*) begin
		case (state)
			S0     : next_state = data ? S1 : S0;
			S1     : next_state = data ? S2 : S1;
			S2     : next_state = data ? S3 : S2;
			S3     : next_state = data ? S0 : S3;
			default: next_state = S0;
		endcase
	end

	always @(posedge clk or negedge rst) begin
		if (~rst) 
			flag <= 1'b0;
		else 
			flag <= ((state == S3) && data);
	end

endmodule