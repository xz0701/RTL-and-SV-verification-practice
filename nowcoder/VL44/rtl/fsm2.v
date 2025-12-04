`timescale 1ns/1ns

module fsm2(
	input wire clk  ,
	input wire rst  ,
	input wire data ,
	output reg flag
);
	parameter S0 = 5'b0_0001,
			  S1 = 5'b0_0010,
			  S2 = 5'b0_0100,
			  S3 = 5'b0_1000,
			  S4 = 5'b1_0000;

	reg [4:0] state, next_state;

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
			S3     : next_state = data ? S4 : S3;
			S4     : next_state = data ? S1 : S0;
			default: next_state = S0;
		endcase
		if (state == S4) begin
			flag = 1'b1;
		end
		else begin
			flag = 1'b0;
		end
	end

endmodule