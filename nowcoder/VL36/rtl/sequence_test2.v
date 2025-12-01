`timescale 1ns/1ns

module sequence_test2(
	input wire clk  ,
	input wire rst  ,
	input wire data ,
	output reg flag
);
//*************code***********//
	parameter IDLE  = 5'b0_0001;
	parameter S1    = 5'b0_0010;
	parameter S10   = 5'b0_0100;
	parameter S101  = 5'b0_1000;
	parameter S1011 = 5'b1_0000;

	reg [4:0] state, next_state;
	always @(posedge clk or negedge rst) begin
		if (~rst) begin
			state <= IDLE;
		end
		else begin
			state <= next_state;
		end
	end

	always @(*) begin
		case (state)
			IDLE:  next_state =  data ? S1    : IDLE;
			S1:    next_state = ~data ? S10   : S1;
			S10:   next_state =  data ? S101  : IDLE;
			S101:  next_state =  data ? S1011 : S10;
			S1011: next_state =  data ? S1    : S10;
			default: 
				   next_state = IDLE;
		endcase
	end

	always @(posedge clk or negedge rst) begin
		if (~rst) begin
			flag <= 1'b0;
		end
		else if (state == S1011) begin
			flag <= 1'b1;
		end
		else begin
			flag <= 1'b0;
		end
	end

//*************code***********//
endmodule