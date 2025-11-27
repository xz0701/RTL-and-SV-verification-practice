`timescale 1ns/1ns
module sequence_detect(
	input clk,
	input rst_n,
	input a,
	output reg match
	);

	parameter IDLE       = 9'b0_0000_0001,
			  S0         = 9'b0_0000_0010,
			  S01        = 9'b0_0000_0100,
			  S011       = 9'b0_0000_1000,
			  S0111      = 9'b0_0001_0000,
			  S01110     = 9'b0_0010_0000,
			  S011100    = 9'b0_0100_0000,
			  S0111000   = 9'b0_1000_0000,
			  S01110001  = 9'b1_0000_0000;

	reg [8:0] state, next_state;
	
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) 
			state <= IDLE;
		else
			state <= next_state;
	end

	always @(*) begin
		case (state)
			IDLE:      next_state = ~a ? S0         : IDLE;
			S0:        next_state =  a ? S01        : S0;
			S01:       next_state =  a ? S011       : S0;
			S011:      next_state =  a ? S0111      : S0;
			S0111:     next_state = ~a ? S01110     : IDLE;
			S01110:    next_state = ~a ? S011100    : S01;
			S011100:   next_state = ~a ? S0111000   : S01;			
			S0111000:  next_state =  a ? S01110001  : S0;
			S01110001: next_state =  a ? S011       : S0;
			default :  next_state = IDLE;
		endcase
	end

	always @(posedge clk or negedge rst_n) begin
		if (~rst_n)
			match <= 1'b0;
		else if (state == S01110001)
			match <= 1'b1;
		else
			match <= 1'b0;
	end
endmodule