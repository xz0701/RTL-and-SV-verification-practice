`timescale 1ns/1ns
module sequence_detect(
	input clk,
	input rst_n,
	input data,
	output reg match,
	output reg not_match
	);

	parameter IDLE    = 13'b0_0000_0000_0001,

			  S0      = 13'b0_0000_0000_0010,
			  S01     = 13'b0_0000_0000_0100,
			  S011    = 13'b0_0000_0000_1000,
			  S0111   = 13'b0_0000_0001_0000,
			  S01110  = 13'b0_0000_0010_0000,
			  S011100 = 13'b0_0000_0100_0000,

			  S6      = 13'b0_0000_1000_0000,
			  S5      = 13'b0_0001_0000_0000,
			  S4      = 13'b0_0010_0000_0000,
			  S3      = 13'b0_0100_0000_0000,
			  S2      = 13'b0_1000_0000_0000,
			  S1      = 13'b1_0000_0000_0000;
//actually for fixed length sequential data, 
//use counter + FSM is a better option
	reg [12:0] state, next_state;
	
	always @(posedge clk or negedge rst_n) begin
		if (~rst_n) 
			state <= IDLE;
		else
			state <= next_state;
	end

	always @(*) begin
		case (state)
			IDLE:       next_state = ~data ? S0      : S6;

			S0:         next_state =  data ? S01     : S5;
			S01:        next_state =  data ? S011    : S4;
			S011:       next_state =  data ? S0111   : S3;
			S0111:      next_state = ~data ? S01110  : S2;
			S01110:     next_state = ~data ? S011100 : S1;
			S011100:    next_state = ~data ? S0      : S6;

			S6:         next_state =  S5;
			S5:         next_state =  S4;
			S4:         next_state =  S3;
			S3:         next_state =  S2;
			S2:         next_state =  S1;
			S1:         next_state = ~data ? S0      : S6;

			default :   next_state = IDLE;
		endcase
	end

	always @(posedge clk or negedge rst_n) begin
		if (~rst_n)
			match <= 1'b0;
		else if (state == S01110 && ~data)
			match <= 1'b1;
		else
			match <= 1'b0;
	end

	always @(posedge clk or negedge rst_n) begin
		if (~rst_n)
			not_match <= 1'b0;
		else if (state == S2 || (state == S01110 && data))
			not_match <= 1'b1;
		else
			not_match <= 1'b0;
	end
endmodule